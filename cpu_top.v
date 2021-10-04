`timescale 1ns/1ps

`include "decoder.vh"

module cpu (
    clk,
    rst_n
);
    parameter START_ADDR = 32'h00000000;

    input wire clk;
    input wire rst_n;


    // The reg file implementation requires a clock twice the speed of the pipeline clock,
    //  so we divide the input clock by two and use that for the pipeline.
    //  f_clk = fast clock, p_clk = pipeline clock
    wire f_clk = clk;
    reg p_clk = 1'b0;
    always @(negedge rst_n, posedge clk)
        if (!rst_n) p_clk <= 1'b0;
        else p_clk <= !p_clk;
    
    
    reg [31:0] PC [3:0];
    initial begin
        PC[0] = START_ADDR;
        PC[1] = 0;
        PC[2] = 0;
        PC[3] = 0;
    end
    always @(posedge p_clk, negedge rst_n)
        if (!rst_n) begin
            PC[0] <= START_ADDR;
            PC[1] <= 0;
            PC[2] <= 0;
            PC[3] <= 0;
        end else begin
            PC[0] <= PC[0] + 4;
            PC[1] <= PC[0];
            PC[2] <= PC[1];
            PC[3] <= PC[2];
        end

    wire [31:0] instruction;

    instruction_memory #(.SIZE_OF_MEMORY(256)) I_mem (
        .clk(p_clk),
        .pc(PC[0]),
        .instruction(instruction)
    );

    wire s1_valid_op;
    wire s1_ALU_OP;
    wire s1_ALU_I_OP;
    wire s1_LOAD_OP;
    wire s1_STORE_OP;
    wire s1_BRANCH_OP;
    wire s1_LUI;
    wire s1_AUIPC;
    wire s1_JAL;
    wire s1_JALR;

    reg s2_valid_op = 0;
    reg s2_ALU_OP = 0;
    reg s2_ALU_I_OP = 0;
    reg s2_LOAD_OP = 0;
    reg s2_STORE_OP = 0;
    reg s2_BRANCH_OP = 0;
    reg s2_LUI = 0;
    reg s2_AUIPC = 0;
    reg s2_JAL = 0;
    reg s2_JALR = 0;

    reg s3_valid_op = 0;
    reg s3_ALU_OP = 0;
    reg s3_ALU_I_OP = 0;
    reg s3_LOAD_OP = 0;
    reg s3_STORE_OP = 0;
    reg s3_BRANCH_OP = 0;
    reg s3_LUI = 0;
    reg s3_AUIPC = 0;
    reg s3_JAL = 0;
    reg s3_JALR = 0;

    decoder control_signal_decoder(
        .instruction(instruction),
        .valid_op(s1_valid_op),
        .ALU_OP(s1_ALU_OP),
        .ALU_I_OP(s1_ALU_I_OP),
        .LOAD_OP(s1_LOAD_OP),
        .STORE_OP(s1_STORE_OP),
        .BRANCH_OP(s1_BRANCH_OP),
        .LUI(s1_LUI),
        .AUIPC(s1_AUIPC),
        .JAL(s1_JAL),
        .JALR(s1_JALR)
    );

    reg [24:0] s2_stripped_instruction = 0;
    always @(posedge p_clk, negedge rst_n)
        if (!rst_n) begin
            s2_stripped_instruction <= 0;
            s2_valid_op <= 0;
            s2_ALU_OP <= 0;
            s2_ALU_I_OP <= 0;
            s2_LOAD_OP <= 0;
            s2_STORE_OP <= 0;
            s2_BRANCH_OP <= 0;
            s2_LUI <= 0;
            s2_AUIPC <= 0;
            s2_JAL <= 0;
            s2_JALR <= 0;            
        end else begin
            s2_stripped_instruction <= instruction[31:7];
            s2_valid_op <= s1_valid_op;
            s2_ALU_OP <= s1_ALU_OP;
            s2_ALU_I_OP <= s1_ALU_I_OP;
            s2_LOAD_OP <= s1_LOAD_OP;
            s2_STORE_OP <= s1_STORE_OP;
            s2_BRANCH_OP <= s1_BRANCH_OP;
            s2_LUI <= s1_LUI;
            s2_AUIPC <= s1_AUIPC;
            s2_JAL <= s1_JAL;
            s2_JALR <= s1_JALR;
        end

    reg [31:0] s3_alu_result = 0;
    wire [31:0] load_result = 0;
    wire [31:0] s2_rs1_v, s2_rs2_v;

    reg [31:0] s3_rd_v;
    always @(*)
        if (s3_ALU_OP)
            s3_rd_v <= s3_alu_result;
        else if (s3_LUI)
            s3_rd_v <= `U_IM(s3_stripped_instruction, 7);
        else if (s3_AUIPC)
            s3_rd_v <= PC[3] + `U_IM(s3_stripped_instruction, 7);
        else
            s3_rd_v <= load_result;

    reg_file registers(
        .rst_n(rst_n),
        .clk(f_clk),
        .rs1(`RS1(instruction, 0)),
        .rs2(`RS2(instruction, 0)),
        .rd(`RD(s3_stripped_instruction, 7)),
        .rs1_v(s2_rs1_v),
        .rs2_v(s2_rs2_v),
        .rd_v(s3_rd_v),
        .we(s3_valid_op && (s3_ALU_OP || s3_LUI || s3_AUIPC || s3_LOAD_OP) )
    );

    wire [31:0] alu_result;
    alu ALU(
        .funct3(`FUNCT3(s2_stripped_instruction, 7)),
        .mod(`FUNCT7_5(s2_stripped_instruction, 7)),
        .val1(s2_rs1_v),
        .val2( (s2_ALU_I_OP) ? `I_IM(s2_stripped_instruction, 7) : s2_rs2_v ),
        .result(alu_result)
    );

    
    reg [24:0] s3_stripped_instruction = 0;
    always @(posedge p_clk, negedge rst_n)
        if (!rst_n) begin
            s3_stripped_instruction <= 0;
            s3_alu_result <= 0;
            s3_valid_op <= 0;
            s3_ALU_OP <= 0;
            s3_ALU_I_OP <= 0;
            s3_LOAD_OP <= 0;
            s3_STORE_OP <= 0;
            s3_BRANCH_OP <= 0;
            s3_LUI <= 0;
            s3_AUIPC <= 0;
            s3_JAL <= 0;
            s3_JALR <= 0;
        end else begin
            s3_alu_result <= alu_result;
            s3_stripped_instruction <= s2_stripped_instruction;
            s3_valid_op <= s2_valid_op;
            s3_ALU_OP <= s2_ALU_OP;
            s3_ALU_I_OP <= s2_ALU_I_OP;
            s3_LOAD_OP <= s2_LOAD_OP;
            s3_STORE_OP <= s2_STORE_OP;
            s3_BRANCH_OP <= s2_BRANCH_OP;
            s3_LUI <= s2_LUI;
            s3_AUIPC <= s2_AUIPC;
            s3_JAL <= s2_JAL;
            s3_JALR <= s2_JALR;
        end


endmodule
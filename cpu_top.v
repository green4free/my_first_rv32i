`timescale 1ns/1ps

`include "decoder.vh"

`define init_pipe(name) \
    wire s1_``name; \
    reg  s2_``name = 0; \
    reg  s3_``name = 0

`define stage_pipe(name) \
    always @(posedge p_clk, negedge rst_n) \
        if (!rst_n) begin \
            s2_``name <= 0; \
            s3_``name <= 0; \
        end else begin \
            s2_``name <= s1_``name; \
            s3_``name <= s2_``name; \
        end

module cpu (
    clk,
    rst_n
);
    parameter START_ADDR = 32'h00000000;

    localparam NOP = 32'h00000013;

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
    
    wire [31:0] s2_rs1_v;
    wire [31:0] s2_rs2_v;

    wire s2_take_branch;
    reg  s3_branch_taken;
    wire s1_invalid;
    reg  s2_invalid = 0;
    reg  s3_invalid = 0;

    reg [31:0] next_instruction_addr;
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
            PC[0] <= next_instruction_addr;
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

    `init_pipe(ALU_OP);
    `init_pipe(ALU_I_OP);
    `init_pipe(LOAD_OP);
    `init_pipe(STORE_OP);
    `init_pipe(BRANCH_OP);
    `init_pipe(LUI);
    `init_pipe(AUIPC);
    `init_pipe(JAL);
    `init_pipe(JALR);

    decoder control_signal_decoder(
        .instruction(instruction),
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

    wire [24:0] s1_stripped_instruction = instruction[31:7];
    reg [24:0] s2_stripped_instruction = 0;
    reg [24:0] s3_stripped_instruction = 0;

    reg [31:0] s3_alu_result = 0;
    wire [31:0] load_result = 0;
    wire [31:0] rs1_v, rs2_v;

    reg [31:0] s3_rd_v;
    always @(*)
        if (s3_ALU_OP)
            s3_rd_v <= s3_alu_result;
        else if (s3_LUI)
            s3_rd_v <= `U_IM(s3_stripped_instruction, 7);
        else if (s3_AUIPC)
            s3_rd_v <= PC[3] + `U_IM(s3_stripped_instruction, 7);
        else if (s3_JAL || s3_JALR)
            s3_rd_v <= PC[3] + 4;
        else
            s3_rd_v <= load_result;

    wire s3_we = (s3_ALU_OP || s3_LUI || s3_AUIPC || s3_JAL || s3_JALR || s3_LOAD_OP) && !s3_invalid;
    reg s4_we = 0;
    reg_file registers(
        .rst_n(rst_n),
        .clk(f_clk),
        .rs1(`RS1(instruction, 0)),
        .rs2(`RS2(instruction, 0)),
        .rd(`RD(s3_stripped_instruction, 7)),
        .rs1_v(rs1_v),
        .rs2_v(rs2_v),
        .rd_v(s3_rd_v),
        .we(s3_we)
    );

    wire [31:0] normal_instruction_transition = PC[0] + 4;

    always @(*)
        if (s2_BRANCH_OP && s2_take_branch && !s2_invalid)
            next_instruction_addr <= `B_IM(s2_stripped_instruction, 7) + PC[2];
        else if (s2_JALR && !s2_invalid)
            next_instruction_addr <= (`I_IM(s2_stripped_instruction, 7) + s2_rs1_v) & 32'hfffffffe;
        else if (s1_JAL && !s1_invalid)
            next_instruction_addr <= `J_IM(s1_stripped_instruction, 7) + PC[1];
        else
            next_instruction_addr <= normal_instruction_transition;
    
    assign s1_invalid = (((s2_take_branch && s2_BRANCH_OP) || s2_JALR || s2_JAL) && !s2_invalid) || ((s3_branch_taken || s3_JALR) && !s3_invalid);

    reg [31:0] s4_rd_v = 0;
    reg [4:0] s4_rd = 0;


    wire rs1_non_zero = `RS1(s2_stripped_instruction, 7) != 0;
    wire rs2_non_zero = `RS2(s2_stripped_instruction, 7) != 0;

    assign s2_rs1_v = (`RS1(s2_stripped_instruction, 7) == `RD(s3_stripped_instruction, 7) && s3_we && rs1_non_zero) ? s3_rd_v :
        ((`RS1(s2_stripped_instruction, 7) == s4_rd && s4_we && rs1_non_zero) ? s4_rd_v : rs1_v);

    assign s2_rs2_v = (`RS2(s2_stripped_instruction, 7) == `RD(s3_stripped_instruction, 7) && s3_we && rs2_non_zero) ? s3_rd_v :
        ((`RS2(s2_stripped_instruction, 7) == s4_rd && s4_we && rs2_non_zero) ? s4_rd_v : rs2_v);

    wire [31:0] alu_val2_i = (s2_ALU_I_OP) ? `I_IM(s2_stripped_instruction, 7) : s2_rs2_v;
    wire [31:0] alu_result;
    alu ALU(
        .funct3(`FUNCT3(s2_stripped_instruction, 7)),
        .mod(`FUNCT7_5(s2_stripped_instruction, 7)),
        .immediate(s2_ALU_I_OP),
        .val1(s2_rs1_v),
        .val2(alu_val2_i),
        .result(alu_result)
    );

    branch_unit BRANCH (
        .funct3(`FUNCT3(s2_stripped_instruction, 7)),
        .val1(s2_rs1_v),
        .val2(s2_rs2_v),
        .take_branch(s2_take_branch)
    );

    
    `stage_pipe(stripped_instruction);
    `stage_pipe(ALU_OP);
    `stage_pipe(ALU_I_OP);
    `stage_pipe(LOAD_OP);
    `stage_pipe(STORE_OP);
    `stage_pipe(BRANCH_OP);
    `stage_pipe(LUI);
    `stage_pipe(AUIPC);
    `stage_pipe(JAL);
    `stage_pipe(JALR);

    always @(posedge p_clk, negedge rst_n)
        if (!rst_n) begin
            s4_rd_v <= 0;
            s4_rd <= 0;
            s3_alu_result <= 0;
            s4_we <= 0;
            s3_branch_taken <= 0;
            s2_invalid <= 0;
            s3_invalid <= 0;
        end else begin
            s4_rd_v <= s3_rd_v;
            s4_rd <= `RD(s3_stripped_instruction, 7);
            s3_alu_result <= alu_result;
            s4_we <= s3_we;
            s3_branch_taken <= s2_take_branch && s2_BRANCH_OP;
            s2_invalid <= s1_invalid;
            s3_invalid <= s2_invalid;
        end

endmodule

`timescale 1ns/1ps

module reg_file(
    rst_n,
    clk,
    rs1,
    rs2,
    rd,
    rs1_v,
    rs2_v,
    rd_v,
    we
);

    input wire        rst_n;
    input wire        clk;
    input wire [4:0]  rs1;
    input wire [4:0]  rs2;
    input wire [4:0]  rd; 
    output reg [31:0] rs1_v = 32'h00000000;
    output reg [31:0] rs2_v = 32'h00000000;
    input wire [31:0] rd_v;
    input wire        we;


    reg [31:0] registers [31:1];
    reg [31:0] rs1_v_intermediate = 32'h00000000;
    reg [4:0]  rs2_intermediate = 5'd0;
    reg step = 1'b1;

    reg [4:0] rd_intermediate = 5'd0;
    reg [31:0] rd_v_intermediate = 32'h00000000;
    reg we_intermediate = 1'b0;

    always @(negedge rst_n, posedge clk)
        if (!rst_n)
            we_intermediate <= 1'b0;
        else
            we_intermediate <= we;

    always @(posedge clk) begin
        rd_intermediate <= rd;
        rd_v_intermediate <= rd_v;
    end
    
    always @(negedge rst_n, posedge clk)
        if (!rst_n)
            step <= 1'b1;
        else
            step <= !step;

    always @(posedge clk) if (we_intermediate && step && |rd_intermediate) registers[rd_intermediate] <= rd_v_intermediate;
    
    
    wire [31:0] register_o = registers[(step) ? rs2_intermediate : rs1];
    
    always @(posedge clk) begin
        if (!step) begin
            rs1_v_intermediate <= (|rs1) ? register_o : 32'h00000000;
            rs2_intermediate <= rs2;
        end else begin
            rs2_v <= (|rs2_intermediate) ? register_o : 32'h00000000;
            rs1_v <= rs1_v_intermediate;
        end
    end

    `ifdef COCOTB_SIM
    integer i;
    initial begin
        for (i=1;i<32;i=i+1)
            registers[i] = 32'h00000000;
    end

    wire [31:0] r1 = registers[1];
    wire [31:0] r2 = registers[2];
    wire [31:0] r3 = registers[3];
    wire [31:0] r4 = registers[4];
    wire [31:0] r5 = registers[5];
    wire [31:0] r6 = registers[6];
    wire [31:0] r7 = registers[7];
    wire [31:0] r8 = registers[8];
    wire [31:0] r9 = registers[9];
    wire [31:0] r10 = registers[10];
    wire [31:0] r11 = registers[11];
    wire [31:0] r12 = registers[12];
    wire [31:0] r13 = registers[13];
    wire [31:0] r14 = registers[14];
    wire [31:0] r15 = registers[15];
    wire [31:0] r16 = registers[16];
    wire [31:0] r17 = registers[17];
    wire [31:0] r18 = registers[18];
    wire [31:0] r19 = registers[19];
    wire [31:0] r20 = registers[20];
    wire [31:0] r21 = registers[21];
    wire [31:0] r22 = registers[22];
    wire [31:0] r23 = registers[23];
    wire [31:0] r24 = registers[24];
    wire [31:0] r25 = registers[25];
    wire [31:0] r26 = registers[26];
    wire [31:0] r27 = registers[27];
    wire [31:0] r28 = registers[28];
    wire [31:0] r29 = registers[29];
    wire [31:0] r30 = registers[30];
    wire [31:0] r31 = registers[31];
    `endif
    
endmodule

`timescale 1ns/1ps

module reg_file_wrapper(
    rst_n,
    clk,
    rs1,
    rs2,
    rd,
    rs1_v,
    rs2_v,
    rd_v,
    we,
    clk_h
);
    
    input wire        rst_n;
    input wire        clk;
    input wire [4:0]  rs1;
    input wire [4:0]  rs2;
    input wire [4:0]  rd; 
    output wire [31:0] rs1_v;
    output wire [31:0] rs2_v;
    input wire [31:0] rd_v;
    input wire        we;

    output reg clk_h = 1'b0;
    always @(negedge rst_n, posedge clk)
        if (!rst_n) clk_h <= 1'b0;
        else clk_h <= !clk_h;
    
    reg_file real_DUT (
        .rst_n(rst_n),
        .clk(clk),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .rs1_v(rs1_v),
        .rs2_v(rs2_v),
        .rd_v(rd_v),
        .we(we)
    );

`ifdef COCOTB_SIM
initial begin
  $dumpfile ("reg_file_wrapper.vcd");
  $dumpvars (0, reg_file_wrapper);
  #1;
end
`endif

endmodule

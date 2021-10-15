
`timescale 1ns/1ps

`define ADD 3'b000
`define SLL 3'b001
`define SLT 3'b010
`define SLTU 3'b011
`define XOR 3'b100
`define SRL 3'b101
`define OR 3'b110
`define AND 3'b111

module alu (
    funct3,
    mod,
    immediate,
    val1,
    val2,
    result
);
    input wire mod;
    input wire immediate;
    input wire [2:0]  funct3;
    input wire [31:0] val1, val2;
    output reg [31:0] result;

    wire signed [31:0] s_val1 = $signed(val1);
    wire signed [31:0] s_val2 = $signed(val2);

    always @(*)
        case (funct3)
            `ADD:  result <= val1 + ((mod && !immediate) ? (~val2) + 1 : val2);
            `SLL:  result <= val1 << val2[4:0];
            `SLT:  result <= (s_val1 < s_val2) ? 32'h00000001 : 32'h00000000;
            `SLTU: result <= (val1 < val2) ? 32'h00000001 : 32'h00000000;
            `XOR:  result <= val1 ^ val2;
            `SRL:  result <= (mod) ? $unsigned(s_val1 >>> val2[4:0]) : (val1 >> val2[4:0]);
            `OR:   result <= val1 | val2;
            `AND:  result <= val1 & val2;
            default: result <= 32'h00000000;
        endcase           
        
    `ifdef COCOTB_SIM
    initial begin
    $dumpfile ("alu.vcd");
    $dumpvars (0, alu);
    #1;
    end
    `endif


endmodule
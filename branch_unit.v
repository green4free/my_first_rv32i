
`define BEQ 3'b000
`define BNE 3'b001
`define BLT 3'b100
`define BLTU 3'b110
`define BGE 3'b101
`define BGEU 3'b111

module branch_unit(
    funct3,
    val1,
    val2,
    take_branch
);
    input wire [2:0]  funct3;
    input wire [31:0] val1, val2;
    output reg take_branch;

    wire signed [31:0] s_val1 = $signed(val1);
    wire signed [31:0] s_val2 = $signed(val2);

    always @(*)
        case (funct3)
            `BEQ:  take_branch <= val1 == val2;
            `BNE:  take_branch <= val1 != val2;
            `BLT:  take_branch <= s_val1 < s_val2;
            `BLTU: take_branch <= val1 < val2;
            `BGE:  take_branch <= s_val1 >= s_val2;
            `BGEU: take_branch <= val1 >= val2;
            default: take_branch <= 1'b0;
        endcase



endmodule
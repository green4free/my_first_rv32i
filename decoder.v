`timescale 1ns/1ps

module decoder(
    instruction,
    valid_op,
    ALU_OP,
    ALU_I_OP,
    LOAD_OP,
    STORE_OP,
    BRANCH_OP,
    LUI,
    AUIPC,
    JAL,
    JALR
);

    input wire [31:0] instruction;
    output wire valid_op;
    // Compute instructions
    output wire ALU_OP;
    output wire ALU_I_OP;
    // Memory instructions
    output wire LOAD_OP;  
    output wire STORE_OP; 
    // Branch instructions
    output wire BRANCH_OP;
    // Special instructions
    output wire LUI;
    output wire AUIPC;
    output wire JAL;
    output wire JALR;

    wire [6:0] opcode = instruction[6:0];
    // Opcode decoding
    assign valid_op  = opcode[0] && opcode[1];
    assign ALU_OP    = opcode[4:2] == 3'b100 && !opcode[6];
    assign ALU_I_OP  = !opcode[5];
    assign LOAD_OP   = opcode[6:2] == 5'b00000;
    assign STORE_OP  = opcode[6:2] == 5'b01000;
    assign BRANCH_OP = opcode[6:2] == 5'b11000;
    assign LUI       = opcode[6:2] == 5'b01101;
    assign AUIPC     = opcode[6:2] == 5'b00101;
    assign JAL       = opcode[6:2] == 5'b11011;
    assign JALR      = opcode[6:2] == 5'b11001;


endmodule
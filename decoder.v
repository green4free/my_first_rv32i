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
    JALR,
    I_IM,
    S_IM,
    B_IM,
    U_IM,
    J_IM,
    rd,
    rs1,
    rs2,
    funct3,
    funct7
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
    // Sign extended and filled out immediates
    output wire [31:0] I_IM;
    output wire [31:0] S_IM;
    output wire [31:0] B_IM;
    output wire [31:0] U_IM; 
    output wire [31:0] J_IM;
    // Register indices
    output wire [4:0] rd;
    output wire [4:0] rs1;
    output wire [4:0] rs2;
    // Function specifiers
    output wire [2:0] funct3;
    output wire [6:0] funct7;

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

    wire extension_bit = instruction[31];
    assign I_IM = {{21{extension_bit}}, instruction[30:20]};
    assign S_IM = {{21{extension_bit}}, instruction[30:25], instruction[11:7]};
    assign B_IM = {{20{extension_bit}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
    assign U_IM = {instruction[31:12], {12{1'b0}}};
    assign J_IM = {{12{extension_bit}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};

    assign rd = instruction[11:7];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];

    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];

    

endmodule


module instruction_memory (
    clk,
    pc,
    instruction
);

    parameter SIZE_OF_MEMORY = 64;//1024;

    input wire clk;
    input wire [31:0] pc;
    output reg [31:0] instruction = 32'h00000000;

    reg [31:0] ROM [SIZE_OF_MEMORY-1 : 0];

    integer i;
    initial begin
        for (i=0; i<SIZE_OF_MEMORY; i=i+1)
            ROM[i] = 0; //Fix loading from file later
    end

    always @(posedge clk)
        instruction <= ROM[pc >> 2];

endmodule
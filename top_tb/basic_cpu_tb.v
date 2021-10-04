`timescale 1ns / 1ps

module basic_cpu_tb();

    reg clk = 0;
    reg rst_n;
    
    always begin
        #5;
        clk <= !clk;
    end
    
    initial begin
        rst_n <= 0;
        #30;
        rst_n <= 1;
    end
    
    cpu DUT(.clk(clk), .rst_n(rst_n));

    initial begin
        DUT.I_mem.ROM[0]  = 32'h00190913;
        DUT.I_mem.ROM[1]  = 32'h00190913;
        DUT.I_mem.ROM[2]  = 32'h00190913;
        DUT.I_mem.ROM[3]  = 32'h00190913;
        DUT.I_mem.ROM[4]  = 32'h00190913;
        DUT.I_mem.ROM[5]  = 32'h00190913;
        DUT.I_mem.ROM[6]  = 32'h00190913;
        DUT.I_mem.ROM[7]  = 32'h00190913;
        DUT.I_mem.ROM[8]  = 32'h00190913;
        DUT.I_mem.ROM[9]  = 32'h00190913;
        DUT.I_mem.ROM[10] = 32'hffb90913;
        DUT.I_mem.ROM[11] = 32'h000019b7;
        DUT.I_mem.ROM[12] = 32'h41298a33;
    end


endmodule

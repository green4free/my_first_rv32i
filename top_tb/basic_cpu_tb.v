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
        //DUT.I_mem.ROM[0]  = 32'h00190913;
        //DUT.I_mem.ROM[1]  = 32'h00190913;
        //DUT.I_mem.ROM[2]  = 32'h00190913;
        //DUT.I_mem.ROM[3]  = 32'h00190913;
        //DUT.I_mem.ROM[4]  = 32'h00190913;
        //DUT.I_mem.ROM[5]  = 32'h00190913;
        //DUT.I_mem.ROM[6]  = 32'h00190913;
        //DUT.I_mem.ROM[7]  = 32'h00190913;
        //DUT.I_mem.ROM[8]  = 32'h00190913;
        //DUT.I_mem.ROM[9]  = 32'h00190913;
        //DUT.I_mem.ROM[10] = 32'hffb90913;
        //DUT.I_mem.ROM[11] = 32'h000019b7;
        //DUT.I_mem.ROM[12] = 32'h41298a33;
        
        //DUT.I_mem.ROM[0] = 32'd1640723;
        //DUT.I_mem.ROM[1] = 32'd13207955;
        //DUT.I_mem.ROM[2] = 32'd20531763;
        //DUT.I_mem.ROM[3] = 32'd4284480239;
        //DUT.I_mem.ROM[4] = 32'd2097744147;
        //DUT.I_mem.ROM[5] = 32'd2097744147;
        //DUT.I_mem.ROM[6] = 32'd2097744147;
        //DUT.I_mem.ROM[7] = 32'd2097744147;

        DUT.I_mem.ROM[0] = 32'd20971759;
        DUT.I_mem.ROM[1] = 32'd4290805907;
        DUT.I_mem.ROM[2] = 32'd4290805907;
        DUT.I_mem.ROM[3] = 32'd4290805907;
        DUT.I_mem.ROM[4] = 32'd4290805907;
        DUT.I_mem.ROM[5] = 32'd32999;
        DUT.I_mem.ROM[6] = 32'd4271894767;
        DUT.I_mem.ROM[7] = 32'd1640723;


    end


endmodule

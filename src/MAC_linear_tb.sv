`timescale 1ns/1ps

module MAC_linear_tb();

localparam CLK_PERIOD = 2;
localparam IDATAWIDTH = 8;
localparam ODATAWIDTH = 8;

logic clk;
logic rst_n;
logic i_valid;
logic signed [IDATAWIDTH-1 : 0] in;
logic signed [ODATAWIDTH-1 : 0] out;
logic o_valid;
logic o_ready;
logic [1:0] section;
logic sim_failed;

logic [IDATAWIDTH-1 : 0] ar, br;


MAC_linear dut(
    .*
);

initial begin
    clk = 1'b0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

initial begin
    rst_n = 1'b0;
    i_valid = 0;
    #5
    rst_n = 1'b1;
    #2;
    i_valid = 1;
    in = 4;
    #CLK_PERIOD
    in = 5;
    #CLK_PERIOD
    i_valid = 0;
    #(CLK_PERIOD*2)
    i_valid = 1;
    in = 6;
    #CLK_PERIOD
    in = 7;
    #CLK_PERIOD
    i_valid = 0;
    #(CLK_PERIOD*3)
    i_valid = 1;
    in = 6;
    #CLK_PERIOD
    i_valid = 0;
    in = 8;
    #CLK_PERIOD
    i_valid = 1;
    in = 7;
    #CLK_PERIOD
    i_valid = 0;
    #(CLK_PERIOD*2)
    i_valid = 1;
    in = -3;
    #CLK_PERIOD
    in = 4;
    #CLK_PERIOD
    i_valid = 0;
    
    
    #15
    $stop();
end



endmodule
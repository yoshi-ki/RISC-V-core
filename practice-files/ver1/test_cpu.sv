`timescale 1ns / 100ps
`default_nettype none

module cpu_tb ();

  // exec cpu for test
  wire rstn = 0;
  wire [31:0] result;
  cpu u1(clk, rstn, result);

  reg clk;
  initial begin
    forever begin
    clk = 0;
    #10 clk = ~clk;
    $display(result);
  end end

end module
`default_nettype wire
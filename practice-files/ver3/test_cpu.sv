`timescale 1ns / 100ps
`default_nettype none

module test_cpu ();

  // exec cpu for test
  wire rstn = 0;
  wire [31:0] result;
  cpu u1(clk, rstn, result);

  reg clk;
  int i;
  initial begin
    // forever begin
    //   clk = 0;
    //   #10 clk = ~clk;
    //   $display(result);
    // end
    clk = 0;
    for (i = 0; i < 100000; i++) begin
      #10 clk = ~clk;
      $display(result);
    end
    $finish;
  end

endmodule
`default_nettype wire
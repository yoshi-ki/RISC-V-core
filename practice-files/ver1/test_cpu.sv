`timescale 1ns / 100ps
`default_nettype none

module cpu_tb ();

  // exec cpu for test
  cpu u1();


  initial begin



    $finish;
  end

end module
`default_nettype wire
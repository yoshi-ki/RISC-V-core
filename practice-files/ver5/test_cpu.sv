`timescale 1ns / 100ps
`default_nettype none

// exec cpu for test
module test_cpu ();

  wire rstn = 0;
  // wire [31:0] result;
  wire completed;
  wire [31:0] registers [0:31];
  int max_clocks = 100000;

  cpu u1(clk, rstn, registers, completed);

  reg clk;
  int clock_count;
  int index;
  initial begin
    clk = 0;
    for (clock_count = 0; clock_count < max_clocks; clock_count++) begin
      #10 clk = ~clk;

      // completed signal
      if (completed) begin
        break;
      end

    end
    $display("clocks: %5d", clock_count);
    for (index = 0; index < 32; index++) begin
      if (index % 4 == 3) begin
        $display("     r%02d: %4d,", index, $signed(registers[index]));
      end else begin
        $write("     r%02d: %4d,", index, $signed(registers[index]));
      end
    end
    $finish;
  end

endmodule
`default_nettype wire
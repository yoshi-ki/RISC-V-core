`default_nettype none

module core (
  input wire CLK,
  output wire [15:0] RESULT
);

  // CPU state
  reg [3:0] = cpu_state;
  localparam s_idle = 0;
  localparam s_fetch = 1;
  localparam s_decode = 2;
  localparam s_execute = 3;
  localparam s_write = 4;
  initial begin
    cpu_state <= s_fetch
  end
  always @(posedge CLK) begin
    case(cpu_status)
      s_fetch: begin
        cpu_state <= s_decode
      end
      s_decode: begin
        cpu_state <= s_execute
      end
      s_execute: begin
        cpu_state <= s_write
      end
      s_write: begin
        cpu_state <= s_fetch
      end
    endcase
  end


  // important components
  reg [31:0] register_int [0:31];
  reg [31:0] pc;
  reg [31:0] executing_inst;


  //constants inst_mem


  always @(posedge CLK) begin

    case(cpu_state)
      // fetch instruction

      // decode instruction
      s_decode: begin
        decoder decode (
          .CLK(CLK),
          .INSTRUCTION(),

          .RD(),
          .RS1(),
          .RS2(),
          .CTR_INFO()
        );
      end
      // case : exec instruction case
      s_execute: begin
        executer execute (
          .CLK(CLK),
          .CTR_INFO(),



        );
      end
      // write back


    endcase

  end


end module
`default_nettype wire
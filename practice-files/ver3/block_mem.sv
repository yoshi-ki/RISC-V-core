`default_nettype none
`include "def.sv"
module block_memory(
  input wire CLK,
  input wire RSTN,
  input wire [4:0] ADDRESS,
  input wire WRITE_ENABLE,
  input wire [31:0] WRITE_DATA,
  output reg [31:0] READ_DATA
);

  localparam memory_size = 1024;
  reg[31:0] memory [0:memory_size - 1];


always @(posedge CLK) begin
  if (WRITE_ENABLE) begin
    memory[ADDRESS] <= WRITE_DATA;
  end
  READ_DATA <= memory[ADDRESS];
end

endmodule
`default_nettype wire
`default_nettype none
`include "def.sv"
module writer(
  input wire CLK,
  input wire RSTN,
  input wire [4:0] RD,
  input wire [31:0] IN_VAL,

);



always @(posedge CLK) begin
end

endmodule
`default_nettype wire
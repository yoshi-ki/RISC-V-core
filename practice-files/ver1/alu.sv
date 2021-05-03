`default_nettype none
`include "def.sv"
module aluer(
  input wire CLK,
  input wire RSTN,
  input control_info CTR_INFO,
  input wire [31:0] RS1_VAL,
  input wire [31:0] RS2_VAL,

  output reg [31:0] ALU_RESULT
);

wire [31:0] result =
  CTR_INFO.add  ? $signed(RS1_VAL) + $signed(RS2_VAL):
  CTR_INFO.sub  ? $signed(RS1_VAL) - $signed(RS2_VAL):
  CTR_INFO.sll  ? RS1_VAL << RS2_VAL:
  CTR_INFO.slt  ? (($signed(RS1_VAL) < $signed(RS2_VAL)) ? 1 : 0):
  CTR_INFO.sltu ? ((RS1_VAL < RS2_VAL) ? 1 : 0):
  CTR_INFO.xor_ ? RS1_VAL ^ RS2_VAL:
  CTR_INFO.srl  ? RS1_VAL >> RS2_VAL[4:0]:
  CTR_INFO.sra  ? $signed(RS1_VAL) >>> RS2_VAL[4:0]:
  CTR_INFO.or_  ? RS1_VAL | RS2_VAL:
  CTR_INFO.and_ ? RS1_VAL & RS2_VAL:
  31'b0;


always @(posedge CLK) begin
  ALU_RESULT <= result;
end

endmodule
`default_nettype wire
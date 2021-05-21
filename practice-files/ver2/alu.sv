`default_nettype none
`include "def.sv"
module aluer(
  input wire CLK,
  input wire RSTN,
  input control_info CTR_INFO,
  input reg [31:0] RS1_VAL,
  input reg [31:0] RS2_VAL,

  output reg [31:0] ALU_RESULT
);

wire [31:0] result =
  // instructions lui, auipc,
  CTR.INFO.lui ? CTR_INFO.immediate:
  CTR_INFO.auipc ? CTR_INFO.pc + $signed(CTR_INFO.immediate):

  // jump instructions
  CTR_INFO.jal  ? CTR_INFO.pc + 1:
  CTR_INFO.jalr ? CTR_INFO.pc + 1:

  // branch instructions
  // do nothing

  // instructions for load and store
  // TODO: implement instructions

  // instructions using immediate and registers
  CTR_INFO.addi  ? $signed(RS1_VAL) + $signed(CTR_INFO.immediate):
  CTR_INFO.slti  ? (($signed(RS1_VAL) < $signed(CTR_INFO.immediate)) ? 1 : 0):
  CTR_INFO.sltiu ? ((RS1_VAL < CTR_INFO.immediate) ? 1 : 0):
  CTR_INFO.xori  ? RS1_VAL ^ CTR_INFO.immediate:
  CTR_INFO.ori   ? RS1_VAL | CTR_INFO.immediate:
  CTR_INFO.andi  ? RS1_VAL & CTR_INFO.immediate:
  CTR_INFO.slli  ? RS1_VAL << CTR_INFO.immediate[4:0]:
  CTR_INFO.srli  ? RS1_VAL >> CTR_INFO.immediate[4:0]:
  CTR_INFO.srai  ? $signed(RS1_VAL) >>> CTR_INFO.immediate[4:0]:

  // instructions using two registers
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
  32'b0;




always @(posedge CLK) begin
  ALU_RESULT <= result;
end

endmodule
`default_nettype wire
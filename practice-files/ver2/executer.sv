`default_nettype none
`include "def.sv"
module executer(
  input wire CLK,
  input wire RSTN,
  input control_info CTR_INFO,
  input reg [31:0] RS1_VAL,
  input reg [31:0] RS2_VAL,
  output wire [31:0] JUMP_DEST,
  output reg [31:0] EXEC_RESULT
);


aluer alu(
  .CLK(CLK),
  .RSTN(RSTN),
  .PC(PC),
  .CTR_INFO(CTR_INFO),
  .RS1_VAL(RS1_VAL),
  .RS2_VAL(RS2_VAL),
  .ALU_RESULT(EXEC_RESULT)
);

// will define fpu
// fpuer fpu(
// );

assign JUMP_DEST = CTR_INFO.jal                                            ? CTR_INFO.pc + $signed(CTR_INFO.immediate):
                  CTR_INFO.jalr                                            ? RS1_VAL + $signed(CTR_INFO.immediate):
                  (CTR_INFO.beq && (RS1_VAL == RS2_VAL))                   ? CTR_INFO.pc + $signed(CTR_INFO.immediate):
                  (CTR_INFO.bne && (RS1_VAL != RS2_VAL))                   ? CTR_INFO.pc + $signed(CTR_INFO.immediate):
                  (CTR_INFO.blt && ($signed(RS1_VAL) < $signed(RS2_VAL)))  ? CTR_INFO.pc + $signed(CTR_INFO.immediate):
                  (CTR_INFO.bge && ($signed(RS1_VAL) >= $signed(RS2_VAL))) ? CTR_INFO.pc + $signed(CTR_INFO.immediate):
                  (CTR_INFO.bltu && (RS1_VAL < RS2_VAL))                   ? CTR_INFO.pc + $signed(CTR_INFO.immediate):
                  (CTR_INFO.bgeu && (RS1_VAL >= RS2_VAL))                  ? CTR_INFO.pc + $signed(CTR_INFO.immediate):
                  CTR_INFO.pc + 1



always @(posedge CLK) begin

end

endmodule
`default_nettype wire
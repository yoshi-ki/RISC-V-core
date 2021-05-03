`default_nettype none
`include "def.sv"
module executer(
  input wire CLK,
  input wire RSTN,
  input control_info CTR_INFO,
  input wire [31:0] RS1_VAL,
  input wire [31:0] RS2_VAL,

  output wire [31:0] EXEC_RESULT
);

wire [31:0] alu_result;
aluer alu(
  .CLK(CLK),
  .RS1_VAL(RS1_VAL),
  .RS2_VAL(RS2_VAL),
  .ALU_RESULT(alu_result)
);


always @(posedge CLK) begin
  EXEC_RESULT <= alu_result;
end

end module
`default_nettype wire
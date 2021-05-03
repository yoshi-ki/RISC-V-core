`default_nettype none
`include "def.sv"
module executer(
  input wire CLK,
  input control_info CTR_INFO,
  input wire [31:0] RS1_VAL,
  input wire [31:0] RS2_VAL,

  output wire [31:0] RESULT
);

wire [31:0] alu_result;
alu aluer(
  .CLK(CLK),
  .RS1_VAL(RS1_VAL),
  .RS2_VAL(RS2_VAL),
  .ALU_RESULT(alu_result)
);


always @(posedge CLK) begin
  RESULT <= alu_result;
end

end module
`default_nettype wire
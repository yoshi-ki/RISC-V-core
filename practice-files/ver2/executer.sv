`default_nettype none
`include "def.sv"
module executer(
  input wire CLK,
  input wire RSTN,
  input control_info CTR_INFO,
  input reg [31:0] RS1_VAL,
  input reg [31:0] RS2_VAL,

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

// TODO: related with PC


always @(posedge CLK) begin

end

endmodule
`default_nettype wire
`default_nettype none
`include "def.sv"
module executer(
  input wire CLK,
  input control_info CTR_INFO,
  input wire [31:0] RS1_VAL,
  input wire [31:0] RS2_VAL,

  output wire[31:0] ALU_RESULT
);

wire result =
  CTR_INFO.add ? : $signed(RS1_VAL) + $signed(RS2_VAL):
  CTR_INFO.sub ? : $signed(RS1_VAL) - $signed(RS2_VAL):
  31'b0;


always @(posedge CLK) begin
  ALU_RESULT <= result;
end

end module
`default_nettype wire
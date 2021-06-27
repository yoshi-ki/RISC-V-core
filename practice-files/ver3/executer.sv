`default_nettype none
`include "def.sv"
module executer(
  input wire CLK,
  input wire RSTN,
  input control_info CTR_INFO,
  input reg [31:0] RS1_VAL,
  input reg [31:0] RS2_VAL,
  output wire [31:0] JUMP_DEST,
  output reg [31:0] EXEC_RD,
  output reg [31:0] MEMORY_OUT
);


aluer alu(
  .CLK(CLK),
  .RSTN(RSTN),
  .CTR_INFO(CTR_INFO),
  .RS1_VAL(RS1_VAL),
  .RS2_VAL(RS2_VAL),
  .ALU_RESULT(EXEC_RD)
);

// will define fpu
// fpuer fpu(
// );

//TODO: watch out this immediate shift
assign JUMP_DEST = CTR_INFO.jal                                            ? $signed(CTR_INFO.pc) + $signed($signed(CTR_INFO.immediate) >>> 2):
                  CTR_INFO.jalr                                            ? $signed(RS1_VAL) + $signed($signed(CTR_INFO.immediate) >>> 2):
                  (CTR_INFO.beq && (RS1_VAL == RS2_VAL))                   ? $signed(CTR_INFO.pc) + $signed($signed(CTR_INFO.immediate) >>> 2):
                  (CTR_INFO.bne && (RS1_VAL != RS2_VAL))                   ? $signed(CTR_INFO.pc) + $signed($signed(CTR_INFO.immediate) >>> 2):
                  (CTR_INFO.blt && ($signed(RS1_VAL) < $signed(RS2_VAL)))  ? $signed(CTR_INFO.pc) + $signed($signed(CTR_INFO.immediate) >>> 2):
                  (CTR_INFO.bge && ($signed(RS1_VAL) >= $signed(RS2_VAL))) ? $signed(CTR_INFO.pc) + $signed($signed(CTR_INFO.immediate) >>> 2):
                  (CTR_INFO.bltu && (RS1_VAL < RS2_VAL))                   ? $signed(CTR_INFO.pc) + $signed($signed(CTR_INFO.immediate) >>> 2):
                  (CTR_INFO.bgeu && (RS1_VAL >= RS2_VAL))                  ? $signed(CTR_INFO.pc) + $signed($signed(CTR_INFO.immediate) >>> 2):
                  CTR_INFO.pc + 1;

wire [31:0] note = ($signed(CTR_INFO.immediate) >>> 2);

// memory instructions
// TODO: configure address length
wire [4:0] address = $signed({1'b0, RS1_VAL}) + $signed(CTR_INFO.immediate);
wire write_enable = (CTR_INFO.sb || CTR_INFO.sh || CTR_INFO.sw) ? 1'b1 : 1'b0;

block_memory memory (
  .CLK(CLK),
  .RSTN(RSTN),
  .ADDRESS(address),
  .WRITE_ENABLE(write_enable),
  .WRITE_DATA(RS2_VAL),
  .READ_DATA(MEMORY_OUT)
);



always @(posedge CLK) begin

end

endmodule
`default_nettype wire
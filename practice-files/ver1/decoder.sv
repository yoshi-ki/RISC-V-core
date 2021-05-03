`default_nettype none
`include "def.sv"
module decoder(
  input wire CLK,
  input wire RSTN,
  input wire [31:0] INSTRUCTION,

  output wire [4:0] RS1,
  output wire [4:0] RS2,
  output control_info CTR_INFO
  // immediate
  // output reg [31:0] IMM,

);


wire [6:0] opcode = INSTRUCTION[6:0];
wire [4:0] rd = INSTRUCTION[11:7];
wire [4:0] rs1 = INSTRUCTION[19:15];
wire [4:0] rs2 = INSTRUCTION[24:20];
wire [2:0] funct3 = INSTRUCTION[14:12];

assign RS1 = rs1;
assign RS2 = rs2;

always @(posedge CLK) begin

  CTR_INFO.add <= 1'b1;
  CTR_INFO.rd <= rd;

end

endmodule
`default_nettype wire
`default_nettype none
`include "def.sv"
module decoder(
  input wire CLK,
  input wire [31:0] INSTRUCTION,

  output wire [4:0] RD,
  output wire [4:0] RS1,
  output wire [4:0] RS2,
  output control_info CTR_INFO
  // immediate
  // output reg [31:0] IMM,

);


wire opcode[6:0] = INSTRUCTION[6:0];
wire rd[4:0] = INSTRUCTION[11:7];
wire rs1[4:0] = INSTRUCTION[19:15];
wire rs2[4:0] = INSTRUCTION[24:20];
wire funct3[2:0] = INSTRUCTION[14:12];

always @(posedge CLK) begin

  CTR_INFO.add <= 1'b1;
  assign RD = rd;
  assign RS1 = rs1;
  assign RS2 = rs2;

end

end module
`default_nettype wire
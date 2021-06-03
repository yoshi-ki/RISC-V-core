`default_nettype none
`include "def.sv"
module decoder(
  input wire CLK,
  input wire RSTN,
  input wire [31:0] INSTRUCTION,
  input wire [31:0] PC,

  output wire [4:0] RS1,
  output wire [4:0] RS2,
  output control_info CTR_INFO

);

wire [6:0] opcode = INSTRUCTION[6:0];
wire [4:0] rd = INSTRUCTION[11:7];
wire [4:0] rs1 = INSTRUCTION[19:15];
wire [4:0] rs2 = INSTRUCTION[24:20];
wire [2:0] funct3_ = INSTRUCTION[14:12];
wire [6:0] funct7_ = INSTRUCTION[31:25];

// Caution: for part of RV32-I and RV32-M!!
wire R_type = (opcode == 7'b0110011);
wire I_type = (opcode == 7'b1100111 | opcode == 7'b0000011 | opcode == 7'b0010011);
wire S_type = (opcode == 7'b0100011);
wire B_type = (opcode == 7'b1100011);
wire U_type = (opcode == 7'b0110111 | opcode == 7'b0010111);
wire J_type = (opcode == 7'b1101111);


// decode the instruction components
assign RS1    = (R_type | I_type | S_type | B_type) ? rs1 : 5'b0;
assign RS2    = (R_type | S_type | B_type)          ? rs2 : 5'b0;
wire [4:0] RD     = (R_type | I_type | U_type | J_type) ? rd : 5'b0;
wire funct3 = (R_type | I_type | S_type | B_type) ? funct3_ : 3'b0;
wire funct7 = (R_type)                            ? funct7_ : 7'b0;
wire [31:0] IMMEDIATE = (I_type) ? (INSTRUCTION[31] ? {~20'b0, INSTRUCTION[31:20]} : {20'b0, INSTRUCTION[31:20]}) :
                (S_type) ? (INSTRUCTION[31] ? {~20'b0, INSTRUCTION[31:25], INSTRUCTION[11:7]} : {20'b0, INSTRUCTION[31:25], INSTRUCTION[11:7]}) :
                (B_type) ? {INSTRUCTION[31] ? {~19'b0, INSTRUCTION[31], INSTRUCTION[7], INSTRUCTION[30:25], INSTRUCTION[11:8]} : {19'b0, INSTRUCTION[31], INSTRUCTION[7], INSTRUCTION[30:25], INSTRUCTION[11:8]}} :
                (U_type) ? {INSTRUCTION[31:12], 12'b0} :
                (J_type) ? {INSTRUCTION[31] ? {~11'b0, INSTRUCTION[19:12], INSTRUCTION[20], INSTRUCTION[30:21], 1'b0} : {11'b0, INSTRUCTION[19:12], INSTRUCTION[20], INSTRUCTION[30:21], 1'b0}} :
                32'b0;


// Identify instructions
wire is_lui    = (opcode == 7'b0110111);
wire is_auipc  = (opcode == 7'b0010111);
wire is_jal    = (opcode == 7'b1101111);
wire is_jalr   = (opcode == 7'b1100111 & funct3 == 3'b0);
wire is_beq    = (opcode == 7'b1100011 & funct3 == 3'b0);
wire is_bne    = (opcode == 7'b1100011 & funct3 == 3'b001);
wire is_blt    = (opcode == 7'b1100011 & funct3 == 3'b100);
wire is_bge    = (opcode == 7'b1100011 & funct3 == 3'b101);
wire is_bltu   = (opcode == 7'b1100011 & funct3 == 3'b110);
wire is_bgeu   = (opcode == 7'b1100011 & funct3 == 3'b111);
wire is_lb     = (opcode == 7'b0000011 & funct3 == 3'b000);
wire is_lh     = (opcode == 7'b0000011 & funct3 == 3'b001);
wire is_lw     = (opcode == 7'b0000011 & funct3 == 3'b010);
wire is_lbu    = (opcode == 7'b0000011 & funct3 == 3'b100);
wire is_lhu    = (opcode == 7'b0000011 & funct3 == 3'b101);
wire is_sb     = (opcode == 7'b0100011 & funct3 == 3'b000);
wire is_sh     = (opcode == 7'b0100011 & funct3 == 3'b001);
wire is_sw     = (opcode == 7'b0100011 & funct3 == 3'b010);
wire is_addi   = (opcode == 7'b0010011 & funct3 == 3'b000);
wire is_slti   = (opcode == 7'b0010011 & funct3 == 3'b010);
wire is_sltiu  = (opcode == 7'b0010011 & funct3 == 3'b011);
wire is_xori   = (opcode == 7'b0010011 & funct3 == 3'b100);
wire is_ori    = (opcode == 7'b0010011 & funct3 == 3'b110);
wire is_andi   = (opcode == 7'b0010011 & funct3 == 3'b111);
wire is_slli   = (opcode == 7'b0010011 & funct3 == 3'b001 & funct7 == 7'b0000000);
wire is_srli   = (opcode == 7'b0010011 & funct3 == 3'b101 & funct7 == 7'b0000000);
wire is_srai   = (opcode == 7'b0010011 & funct3 == 3'b101 & funct7 == 7'b0100000);
wire is_add    = (opcode == 7'b0110011 & funct3 == 3'b000 & funct7 == 7'b0000000);
wire is_sub    = (opcode == 7'b0110011 & funct3 == 3'b000 & funct7 == 7'b0100000);
wire is_sll    = (opcode == 7'b0110011 & funct3 == 3'b001 & funct7 == 7'b0000000);
wire is_slt    = (opcode == 7'b0110011 & funct3 == 3'b010 & funct7 == 7'b0000000);
wire is_sltu   = (opcode == 7'b0110011 & funct3 == 3'b011 & funct7 == 7'b0000000);
wire is_xor    = (opcode == 7'b0110011 & funct3 == 3'b100 & funct7 == 7'b0000000);
wire is_srl    = (opcode == 7'b0110011 & funct3 == 3'b101 & funct7 == 7'b0000000);
wire is_sra    = (opcode == 7'b0110011 & funct3 == 3'b101 & funct7 == 7'b0100000);
wire is_or     = (opcode == 7'b0110011 & funct3 == 3'b110 & funct7 == 7'b0000000);
wire is_and    = (opcode == 7'b0110011 & funct3 == 3'b111 & funct7 == 7'b0000000);
wire is_mul    = (opcode == 7'b0110011 & funct3 == 3'b000 & funct7 == 7'b0000001);
wire is_mulh   = (opcode == 7'b0110011 & funct3 == 3'b001 & funct7 == 7'b0000001);
wire is_mulhsu = (opcode == 7'b0110011 & funct3 == 3'b010 & funct7 == 7'b0000001);
wire is_mulhu  = (opcode == 7'b0110011 & funct3 == 3'b011 & funct7 == 7'b0000001);
wire is_div    = (opcode == 7'b0110011 & funct3 == 3'b100 & funct7 == 7'b0000001);
wire is_divu   = (opcode == 7'b0110011 & funct3 == 3'b101 & funct7 == 7'b0000001);
wire is_rem    = (opcode == 7'b0110011 & funct3 == 3'b110 & funct7 == 7'b0000001);
wire is_remu   = (opcode == 7'b0110011 & funct3 == 3'b111 & funct7 == 7'b0000001);



always @(posedge CLK) begin

  CTR_INFO.lui <= is_lui;
  CTR_INFO.auipc <= is_auipc;
  CTR_INFO.jal <= is_jal;
  CTR_INFO.jalr <= is_jalr;
  CTR_INFO.beq <= is_beq;
  CTR_INFO.bne <= is_bne;
  CTR_INFO.blt <= is_blt;
  CTR_INFO.bge <= is_bge;
  CTR_INFO.bltu <= is_bltu;
  CTR_INFO.bgeu <= is_bgeu;
  CTR_INFO.lb <= is_lb;
  CTR_INFO.lh <= is_lh;
  CTR_INFO.lw <= is_lw;
  CTR_INFO.lbu <= is_lbu;
  CTR_INFO.lhu <= is_lhu;
  CTR_INFO.sb <= is_sb;
  CTR_INFO.sh <= is_sh;
  CTR_INFO.sw <= is_sw;
  CTR_INFO.addi <= is_addi;
  CTR_INFO.slti <= is_slti;
  CTR_INFO.sltiu <= is_sltiu;
  CTR_INFO.xori <= is_xori;
  CTR_INFO.ori <= is_ori;
  CTR_INFO.andi <= is_andi;
  CTR_INFO.slli <= is_slli;
  CTR_INFO.srli <= is_srli;
  CTR_INFO.srai <= is_srai;
  CTR_INFO.add <= is_add;
  CTR_INFO.sub <= is_sub;
  CTR_INFO.sll <= is_sll;
  CTR_INFO.slt <= is_slt;
  CTR_INFO.sltu <= is_sltu;
  CTR_INFO.xor_ <= is_xor;
  CTR_INFO.srl <= is_srl;
  CTR_INFO.sra <= is_sra;
  CTR_INFO.or_ <= is_or;
  CTR_INFO.and_ <= is_and;

  CTR_INFO.mul <= is_mul;
  CTR_INFO.mulh <= is_mulh;
  CTR_INFO.mulhsu <= is_mulhsu;
  CTR_INFO.mulhu <= is_mulhu;
  CTR_INFO.div <= is_div;
  CTR_INFO.divu <= is_divu;
  CTR_INFO.rem <= is_rem;
  CTR_INFO.remu <= is_remu;


  CTR_INFO.rd <= RD;
  CTR_INFO.immediate <= IMMEDIATE;
  CTR_INFO.pc <= PC;

end

endmodule
`default_nettype wire


// `default_nettype none
// `include "def.sv"
// module decoder(
//   input wire CLK,
//   input wire RSTN,
//   input wire [31:0] INSTRUCTION,

//   output wire [4:0] RS1,
//   output wire [4:0] RS2,
//   output control_info CTR_INFO
//   // immediate
//   // output reg [31:0] IMM,

// );


// wire [6:0] opcode = INSTRUCTION[6:0];
// wire [4:0] rd = INSTRUCTION[11:7];
// wire [4:0] rs1 = INSTRUCTION[19:15];
// wire [4:0] rs2 = INSTRUCTION[24:20];
// wire [2:0] funct3 = INSTRUCTION[14:12];

// assign RS1 = rs1;
// assign RS2 = rs2;

// always @(posedge CLK) begin

//   CTR_INFO.add <= 1'b1;
//   CTR_INFO.rd <= rd;

// end

// endmodule
// `default_nettype wire
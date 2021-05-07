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
assign RD     = (R_type | I_type | U_type | J_type) ? rd  : 5'b0;
assign funct3 = (R_type | I_type | S_type | B_type) ? funct3_ : 3'b0;
assign funct7 = (R_type)                            ? funct7_ : 7'b0;
assign IMMEDIATE = (I_type) ? (INSTRUCTION[31] ? {~20'b0, INSTRUCTION[31:20]} : {20'b0, INSTRUCTION[31:20]}) :
                  (S_type) ? (INSTRUCTION[31] ? {~20'b0, INSTRUCTION[31:25], INSTRUCTION[11:7]} : {20'b0, INSTRUCTION[31:25], INSTRUCTION[11:7]}) :
                  (B_type) ? {INSTRUCTION[31] ? {~19'b0, INSTRUCTION[31], INSTRUCTION[7], INSTRUCTION[30:25], INSTRUCTION[11:8]} : {19'b0, INSTRUCTION[31], INSTRUCTION[7], INSTRUCTION[30:25], INSTRUCTION[11:8]}} :
                  (U_type) ? {INSTRUCTION[31] ? {INSTRUCTION[31:12], 12'b0}} :
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

  CTR_INFO.add <= is_add;
  CTR_INFO.rd <= RD;
  CTR_INFO.immediate <= IMMEDIATE;

end

endmodule
`default_nettype wire
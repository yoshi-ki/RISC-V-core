`default_nettype none
`include "def.sv"
module writer(
  input wire CLK,
  input wire RSTN,
  input reg WRITER_ENABLED,
  input reg [31:0] REGISTER_FILE [0:31],
  input control_info CTR_INFO,
  input reg [31:0] EXEC_RD,
  input reg [31:0] MEMORY_OUT,
  output wire WRITE_ENABLE,
  output wire [31:0] WRITE_DATA
);

  wire write_enable = (CTR_INFO.rd == 5'b0) ? 1'b0 :
                      (CTR_INFO.lui  ||
                      CTR_INFO.auipc ||
                      CTR_INFO.jal   ||
                      CTR_INFO.jalr  ||
                      CTR_INFO.addi  ||
                      CTR_INFO.slti  ||
                      CTR_INFO.sltiu ||
                      CTR_INFO.xori  ||
                      CTR_INFO.ori   ||
                      CTR_INFO.andi  ||
                      CTR_INFO.slli  ||
                      CTR_INFO.srli  ||
                      CTR_INFO.srai  ||
                      CTR_INFO.add   ||
                      CTR_INFO.sub   ||
                      CTR_INFO.sll   ||
                      CTR_INFO.slt   ||
                      CTR_INFO.sltu  ||
                      CTR_INFO.xor_  ||
                      CTR_INFO.srl   ||
                      CTR_INFO.sra   ||
                      CTR_INFO.or_   ||
                      CTR_INFO.and_  ||
                      CTR_INFO.lb    ||
                      CTR_INFO.lh    ||
                      CTR_INFO.lw    ||
                      CTR_INFO.lbu   ||
                      CTR_INFO.lhu
                      ) ? 1'b1 : 1'b0;

  assign WRITE_ENABLE = write_enable;

  wire [31:0] write_data = (CTR_INFO.lui  ||
                    CTR_INFO.auipc ||
                    CTR_INFO.jal   ||
                    CTR_INFO.jalr  ||
                    CTR_INFO.addi  ||
                    CTR_INFO.slti  ||
                    CTR_INFO.sltiu ||
                    CTR_INFO.xori  ||
                    CTR_INFO.ori   ||
                    CTR_INFO.andi  ||
                    CTR_INFO.slli  ||
                    CTR_INFO.srli  ||
                    CTR_INFO.srai  ||
                    CTR_INFO.add   ||
                    CTR_INFO.sub   ||
                    CTR_INFO.sll   ||
                    CTR_INFO.slt   ||
                    CTR_INFO.sltu  ||
                    CTR_INFO.xor_  ||
                    CTR_INFO.srl   ||
                    CTR_INFO.sra   ||
                    CTR_INFO.or_   ||
                    CTR_INFO.and_
                    ) ? EXEC_RD:
                    (CTR_INFO.lb ||
                    CTR_INFO.lh  ||
                    CTR_INFO.lw  ||
                    CTR_INFO.lbu ||
                    CTR_INFO.lhu
                    ) ? MEMORY_OUT:
                    32'b0;

  assign WRITE_DATA = write_data;

always @(posedge CLK) begin
  // if(write_enable & WRITER_ENABLED) begin
  //   REGISTER_FILE[CTR_INFO.rd] <= write_data;
  // end
end

endmodule
`default_nettype wire
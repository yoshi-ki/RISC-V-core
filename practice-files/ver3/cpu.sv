`default_nettype none
`include "def.sv"

module cpu (
  input wire CLK,
  input wire RSTN,
  output wire [31:0] RESULT
);

  // define CPU state
  reg [3:0] cpu_state;
  localparam s_idle = 0;
  localparam s_fetch = 1;
  localparam s_decode = 2;
  localparam s_execute = 3;
  localparam s_write = 4;
  initial begin
    cpu_state <= s_fetch;
  end
  always @(posedge CLK) begin
    case(cpu_state)
      s_fetch: begin
        cpu_state <= s_decode;
      end
      s_decode: begin
        cpu_state <= s_execute;
      end
      s_execute: begin
        cpu_state <= s_write;
      end
      s_write: begin
        cpu_state <= s_fetch;
      end
    endcase
  end


  // important components
  reg [31:0] register_file [0:31];
  reg [31:0] pc;
  reg [31:0] executing_inst;


  ////////////////////
  // code for test
  ////////////////////
  //constants inst_mem
  assign RESULT = register_file[14];
  reg [31:0] inst_mem [0:35] = '{
    32'b00000111010000000000000011101111,
    32'b11111110000000010000000100010011,
    32'b00000000000100010010111000100011,
    32'b00000000100000010010110000100011,
    32'b00000000100100010010101000100011,
    32'b00000010000000010000010000010011,
    32'b11111110101001000010011000100011,
    32'b11111110110001000010011100000011,
    32'b00000000000100000000011110010011,
    32'b00000000111001111100011001100011,
    32'b00000000000100000000011110010011,
    32'b00000011000000000000111111101111, // 11 j 5c <fib+0x58> zero register
    32'b11111110110001000010011110000011,
    32'b11111111111101111000011110010011,
    32'b00000000000001111000010100010011,
    32'b11111100100111111111000011101111,
    32'b00000000000001010000010010010011,
    32'b11111110110001000010011110000011,
    32'b11111111111001111000011110010011,
    32'b00000000000001111000010100010011,
    32'b11111011010111111111000011101111,
    32'b00000000000001010000011110010011,
    32'b00000000111101001000011110110011,
    32'b00000000000001111000010100010011,
    32'b00000001110000010010000010000011,
    32'b00000001100000010010010000000011,
    32'b00000001010000010010010010000011,
    32'b00000010000000010000000100010011,
    32'b00000000000000001000111111100111,  // 28 ret
    32'b11111111000000010000000100010011,
    32'b00000000000100010010011000100011,
    32'b00000000100000010010010000100011,
    32'b00000001000000010000010000010011,
    32'b00000000001100000000010100010011,
    32'b11110111110111111111000011101111,
    32'b00000000000000000000000001101111
  };
  int reg_index; // index used for register initialization
  initial begin
    pc <= 0;
    // initialize register_file
    for(reg_index = 0; reg_index < 32; reg_index = reg_index + 1) begin // i++, ++iとは記述できない
      if (reg_index == 2)
        register_file[reg_index] <= 500;
      else
        register_file[reg_index] <= 32'b0;
    end
  end


  ////////////////////
  // define variables
  ////////////////////
  // need for overall
  control_info ctr_info;
  // need for fetch stage
  reg [31:0] instruction;
  // need for decode stage
  wire [4:0] rs1;
  wire [4:0] rs2;
  decoder decode (
    .CLK(CLK),
    .RSTN(RSTN),
    .INSTRUCTION(instruction),
    .PC(pc),
    .RS1(rs1),
    .RS2(rs2),
    .CTR_INFO(ctr_info)
  );
  reg [31:0] rs1_val;
  reg [31:0] rs2_val;
  // need for execute stage
  wire [31:0] jump_dest;
  reg [31:0] exec_rd;
  reg [31:0] memory_out;
  executer execute (
    .CLK(CLK),
    .RSTN(RSTN),
    .CTR_INFO(ctr_info),
    .RS1_VAL(rs1_val),
    .RS2_VAL(rs2_val),
    .JUMP_DEST(jump_dest),
    .EXEC_RD(exec_rd),
    .MEMORY_OUT(memory_out)
  );
  // need for write stage
  wire write_enable;
  wire [31:0] write_data;
  writer write(
    .CLK(CLK),
    .RSTN(RSTN),
    .CTR_INFO(ctr_info),
    .EXEC_RD(exec_rd),
    .MEMORY_OUT(memory_out),
    .WRITE_ENABLE(write_enable),
    .WRITE_DATA(write_data)
  );



  ////////////////////
  // define each stage
  ////////////////////
  always @(posedge CLK) begin

    case(cpu_state)
      // fetch instruction
      s_fetch: begin
        instruction <= inst_mem[pc];
      end

      // decode instruction
      s_decode: begin
        rs1_val <= register_file[rs1];
        rs2_val <= register_file[rs2];
      end

      // case : exec instruction case
      s_execute: begin
        pc <= jump_dest;
      end

      // write back
      s_write: begin
        if(write_enable) begin
          register_file[ctr_info.rd] <= write_data;
        end
      end

    endcase

  end


endmodule
`default_nettype wire
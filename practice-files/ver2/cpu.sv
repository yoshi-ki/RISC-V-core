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
  assign RESULT = register_file[3];
  reg [31:0] inst_mem [0:11] = '{
    32'b00000000001000011000000110110011, // ADD 3(rs1) + 2(rs2) = 3(rd)
    32'b00000000001000011000000110110011, // ADD 3(rs1) + 2(rs2) = 3(rd)
    32'b00000000001000011000000110110011, // ADD 3(rs1) + 2(rs2) = 3(rd)
    32'b00000000001000011000000110110011, // ADD 3(rs1) + 2(rs2) = 3(rd)
    32'b00000000001000011000000110110011, // ADD 3(rs1) + 2(rs2) = 3(rd)
    32'b00000000001000011000000110110011,  // ADD 3(rs1) + 2(rs2) = 3(rd)
    32'b00000000001000011000000110110011,  // ADD 3(rs1) + 2(rs2) = 3(rd)
    32'b00000000001000011000000110110011,  // ADD 3(rs1) + 2(rs2) = 3(rd)
    32'b00000000001000011000000110110011,  // ADD 3(rs1) + 2(rs2) = 3(rd)
    32'b00000000001000011000000110110011,  // ADD 3(rs1) + 2(rs2) = 3(rd)
    32'b00000000001000011000000110110011,  // ADD 3(rs1) + 2(rs2) = 3(rd)
    32'b00000000001000011000001010110011  // ADD 3(rs1) + 2(rs2) = 5(rd)
  };
  initial begin
    pc <= 0;
    register_file[2] <= 2;
    register_file[3] <= 1;
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
    .RS1(rs1),
    .RS2(rs2),
    .CTR_INFO(ctr_info)
  );
  reg [31:0] rs1_val;
  reg [31:0] rs2_val;
  // need for execute stage
  reg [31:0] exec_result;
  executer execute (
    .CLK(CLK),
    .RSTN(RSTN),
    .CTR_INFO(ctr_info),
    .RS1_VAL(rs1_val),
    .RS2_VAL(rs2_val),
    .EXEC_RESULT(exec_result)
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
        pc <= pc + 1;
        rs1_val <= register_file[rs1];
        rs2_val <= register_file[rs2];
      end

      // case : exec instruction case
      s_execute: begin
      end

      // write back
      s_write: begin
        register_file[ctr_info.rd] <= exec_result;
      end

    endcase

  end


endmodule
`default_nettype wire
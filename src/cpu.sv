`default_nettype none
`include "def.sv"

module cpu (
  input wire CLK,
  input wire RSTN,
  input wire INTERRUPT,
  output reg [31:0] register_file [0:31],
  output reg completed
);

  // Note that we have to change this val when you want to change the number of instructions.
  wire [31:0] final_pc = 32'd35;
  wire [31:0] mtvec_pc = 32'd36;

  // define cpu mode
  reg cpu_mode;
  localparam user_mode = 0;
  localparam machine_mode = 1;

  // define important components
  reg [31:0] pc;
  reg [31:0] executing_inst;
  csr_registers csr_register;

  // define control flags
  reg decoder_enabled;
  reg executer_enabled;
  reg writer_enabled;


  ////////////////////
  // code for test
  ////////////////////
  //constants inst_mem
  // assign RESULT = register_file[14];
  reg [31:0] inst_mem [0:35] = '{
    32'b00000111010000000000000011101111,  //  0. jal	ra,74 <main>
    32'b11111110000000010000000100010011,  //  1. addi	sp(=r2),sp,-32
    32'b00000000000100010010111000100011,  //  2. sw	ra(=r1),28(sp)
    32'b00000000100000010010110000100011,  //  3. sw	s0(=r8),24(sp)
    32'b00000000100100010010101000100011,  //  4. sw	s1(=r9),20(sp)
    32'b00000010000000010000010000010011,  //  5. addi	s0,sp,32
    32'b11111110101001000010011000100011,  //  6. sw	a0(=r10),-20(s0)
    32'b11111110110001000010011100000011,  //  7. lw	a4(=r14),-20(s0)
    32'b00000000000100000000011110010011,  //  8. li	a5(=r15),1
    32'b00000000111001111100011001100011,  //  9. blt	a5,a4,30 <fib+0x2c>
    32'b00000000000100000000011110010011,  // 10. li	a5,1
    32'b00000011000000000000000001101111,  // 11. j	5c <fib+0x58>
    32'b11111110110001000010011110000011,  // 12. lw	a5,-20(s0)
    32'b11111111111101111000011110010011,  // 13. addi	a5,a5,-1
    32'b00000000000001111000010100010011,  // 14. mv	a0,a5
    32'b11111100100111111111000011101111,  // 15. jal	ra,4 <fib>
    32'b00000000000001010000010010010011,  // 16. mv	s1,a0
    32'b11111110110001000010011110000011,  // 17. lw	a5,-20(s0)
    32'b11111111111001111000011110010011,  // 18. addi	a5,a5,-2
    32'b00000000000001111000010100010011,  // 19. mv	a0,a5
    32'b11111011010111111111000011101111,  // 20. jal	ra,4 <fib>
    32'b00000000000001010000011110010011,  // 21. mv	a5,a0
    32'b00000000111101001000011110110011,  // 22. add	a5,s1,a5
    32'b00000000000001111000010100010011,  // 23. mv	a0,a5
    32'b00000001110000010010000010000011,  // 24. lw	ra,28(sp)
    32'b00000001100000010010010000000011,  // 25. lw	s0,24(sp)
    32'b00000001010000010010010010000011,  // 26. lw	s1,20(sp)
    32'b00000010000000010000000100010011,  // 27. addi	sp,sp,32
    32'b00000000000000001000000001100111,  // 28. ret
    32'b11111111000000010000000100010011,  // 29. addi	sp,sp,-16
    32'b00000000000100010010011000100011,  // 30. sw	ra,12(sp)
    32'b00000000100000010010010000100011,  // 31. sw	s0,8(sp)
    32'b00000001000000010000010000010011,  // 32. addi	s0,sp,16
    32'b00000000101000000000010100010011,  // 33. li	a0,10
    32'b11110111110111111111000011101111,  // 34. jal	ra,4 <fib>
    32'b00000000000000000000000001101111   // 35. j	8c <main+0x18>
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

    decoder_enabled <= 1;
    executer_enabled <= 1;
    writer_enabled <= 1;

    cpu_mode <= user_mode;
    csr_register.mtvec <= mtvec_pc;
  end


  ////////////////////
  // define variables
  ////////////////////
  // need for overall
  control_info ctr_info_d;
  control_info ctr_info_e;
  // need for fetch stage
  reg [31:0] instruction;
  // need for decode stage
  decoder decode (
    .CLK(CLK),
    .RSTN(RSTN),
    .DECODER_ENABLED(decoder_enabled),
    .INSTRUCTION(instruction),
    .PC(pc),
    .CONDITIONAL_JUMP(conditional_jump),
    .CTR_INFO(ctr_info_d)
  );
  // need for execute stage
  wire [31:0] jump_dest;
  reg [31:0] exec_rd;
  reg [31:0] memory_out;
  executer execute (
    .CLK(CLK),
    .RSTN(RSTN),
    .EXECUTER_ENABLED(executer_enabled),
    .REGISTER_FILE(register_file),
    .CTR_INFO(ctr_info_d),
    .FORWARDED_VAL(write_data),
    .JUMP_DEST(jump_dest),
    .EXEC_RD(exec_rd),
    .MEMORY_OUT(memory_out),
    .CTR_INFO_OUT(ctr_info_e)
  );
  // need for write stage
  wire write_enable;
  wire [31:0] write_data;
  writer write(
    .CLK(CLK),
    .RSTN(RSTN),
    .WRITER_ENABLED(writer_enabled),
    .REGISTER_FILE(register_file),
    .CTR_INFO(ctr_info_e),
    .EXEC_RD(exec_rd),
    .MEMORY_OUT(memory_out),
    .WRITE_ENABLE(write_enable),
    .WRITE_DATA(write_data)
  );


  // define conditional jump
  wire conditional_jump;
  reg [3:0] conditional_jump_count;
  initial begin
    conditional_jump_count <= 3'b0;
  end


  ////////////////////
  // define each stage
  ////////////////////
  always @(posedge CLK) begin

    completed <= (ctr_info_e.pc == final_pc+1);

    // stall controller
    // stall when conditional jump write and execute not disabled
    if(conditional_jump == 1 & conditional_jump_count == 0) begin
      // conditional instruction is in decode stage
      conditional_jump_count <= 1;
      decoder_enabled <= 0;
    end
    else if(conditional_jump_count == 1) begin
      // conditional instruction is in execute stage
      conditional_jump_count <= 2;
      pc <= jump_dest-1; // -1 because we want the pc in fetch stage not decode stage
    end
    else if(conditional_jump_count == 2) begin
      // conditional instruction is in write stage
      conditional_jump_count <= 0;
      decoder_enabled <= 1;
      pc <= pc + 1;
    end
    else begin
      pc <= pc + 1;
    end

    // fetch instruction
    instruction <= inst_mem[pc];

    // decode instruction

    // write back
    if(write_enable & writer_enabled) begin
      register_file[ctr_info_e.rd] <= write_data;
    end


    // when the interrupt is come
    if (INTERRUPT) begin

    end

  end


endmodule
`default_nettype wire
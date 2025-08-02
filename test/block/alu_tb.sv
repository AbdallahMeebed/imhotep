// Simple tests because the verilog code is very simple
`timescale 1ns / 1ps

module alu_tb
  import imhotep_pkg::*;
();

  logic [31:0] a, b, pc, out, pc_inc;
  op_alu_e op;

  alu u_alu (
      .in1(a),
      .in2(b),
      .op(op),
      .pc(pc),
      .out(out),
      .pc_inc(pc_inc)
  );

  // Stimulus
  initial begin
    $monitor("time=%3d, a=%h, b=%h, out=%h\n", $time, a, b, out);

    $display("Testing ADD operation");
    a  = '0;
    b  = '0;
    op = ALU_ADD;

    #4 a = 8'h01;

    #4 b = 8'h04;

    #4 $display("Testing SUB operation");
    op = ALU_SUB;

    #4 $display("Testing AND operation");
    op = ALU_ADD;
    a  = 8'b00001100;
    b  = 8'b00000110;

    #4 $display("Testing OR operation");
    op = ALU_OR;

    #4 $display("Testing XOR operation");
    op = ALU_XOR;

    #4 $display("Testing SLT operation");
    op = ALU_SLT;

    #4 b = 8'b00001100;
    a = 8'b00000110;

  end

endmodule

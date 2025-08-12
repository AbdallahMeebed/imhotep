// Simple tests because the verilog code is very simple
`timescale 1ns / 1ps

module alu_tb
  import imhotep_pkg::*;
();

  logic [XLEN-1:0] a, b, pc, out, pc_inc;
  op_alu_e op;

  alu u_alu (
      .a_i(a),
      .b_i(b),
      .op_i(op),
      .pc_i(pc),
      .out_o(out),
      .pc_inc_o(pc_inc)
  );

  // Stimulus
  initial begin
    $monitor("time=%3d, OP=%s, a=%h, b=%h, out=%h\n", $time, op.name(), a, b, out);

    a  = '0;
    b  = '0;
    op = ALU_ADD;

    #4 a = 32'h00000001;

    #4 b = 32'h00000004;

    #4 op = ALU_SUB;

    #4 op = ALU_AND;
    a = {{XLEN - 8{1'b0}}, 8'b00001100};
    b = {{XLEN - 8{1'b0}}, 8'b00000110};

    #4 op = ALU_OR;

    #4 op = ALU_XOR;

    #4 op = ALU_SLT;

    #4 b = {{XLEN - 8{1'b0}}, 8'b00001100};
    a = {{XLEN - 8{1'b0}}, 8'b00000110};

  end

endmodule

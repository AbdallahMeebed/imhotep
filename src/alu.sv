// Arithmetic and Logic unit

module alu
  import imhotep_pkg::*;
(
    input logic [XLEN - 1:0] in1_i,
    input logic [XLEN - 1:0] in2_i,
    input logic [XLEN - 1:0] pc_i,
    input op_alu_e op_i,
    output logic [XLEN - 1:0] out_o,
    output logic [31:0] pc_inc_o  // increment for jump instructions
);

  logic [XLEN - 1:0] add_inter;
  always_comb begin
    pc_inc_o = pc_i + 4;
    add_inter = in1_i + in2_i;
    case (op_i)
      ALU_ADD:  out_o = add_inter;
      ALU_SUB:  out_o = in1_i - in2_i;
      ALU_AND:  out_o = in1_i & in2_i;
      ALU_OR:   out_o = in1_i | in2_i;
      ALU_XOR:  out_o = in1_i ^ in2_i;
      ALU_SLT:  out_o = (in1_i < in2_i) ? {{XLEN - 1{1'b0}}, 1'b1} : '0;
      ALU_JMPR: out_o = {add_inter[XLEN - 1:1], 1'b0};
      ALU_NOP:  out_o = '0;
      default:  out_o = '0;
    endcase
  end

endmodule

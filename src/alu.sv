// Arithmetic and Logic unit

module alu
  import imhotep_pkg::*;
(
    input logic [31:0] in1,
    in2,
    pc,
    input op_alu_e op,
    output logic [31:0] out,
    pc_inc  // increment for jump instructions
);

  logic [31:0] add_inter;
  always_comb begin
    pc_inc = pc + 4;
    add_inter = in1 + in2;
    case (op)
      ALU_ADD:  out = add_inter;
      ALU_SUB:  out = in1 - in2;
      ALU_AND:  out = in1 & in2;
      ALU_OR:   out = in1 | in2;
      ALU_XOR:  out = in1 ^ in2;
      ALU_SLT:  out = (in1 < in2) ? 8'h01 : 8'h00;
      ALU_JMPR: out = {add_inter[31:1], 1'b0};
      default:  out = 8'h00;
    endcase
  end

endmodule

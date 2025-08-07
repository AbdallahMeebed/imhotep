// Right now handles conditions to see whether to jump or not
module csr
  import imhotep_pkg::*;
(
    input logic [XLEN - 1:0] a_i,
    input logic [XLEN - 1:0] b_i,
    input op_csr_e op_i,
    output logic out_o,  // If branch condition is true or false
    output logic error_o
);

  logic a_s, b_s;  // signed

  always_comb begin
    out_o = 1'b0;
    error = 1'b0;
    a_s = signed'(a_i);
    b_s = signed'(b_i);
    case (op_i)
      CSR_BLT:  out_o = (a_s < b_s);
      CSR_BNE:  out_o = (a_i != b_i);
      CSR_BEQ:  out_o = (a_i == b_i);
      CSR_BLTU: out_o = (a_i < b_i);
      CSR_BGE:  out_o = (a_s >= b_s);
      CSR_BGEU: out_o = (a_i >= b_i);
      CSR_JMP:  out_o = 1'b1;
      CSR_NOP:  out_o = 1'b0;
      default:  error_o = 1'b1;
    endcase
  end

endmodule

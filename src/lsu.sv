// Load store unit
module lsu
  import imhotep_pkg::*;
(
    // Processor interface
    input logic [RAM_WIDTH - 1:0] addr_i,
    input op_lsu_e op_i,
    input logic [XLEN - 1:0] value_proc_i,
    output logic [XLEN - 1:0] value_proc_o,

    input logic [XLEN - 1:0] value_ram_i,
    output logic [XLEN - 1:0] value_ram_o,
    output logic [RAM_WIDTH - 1:0] addr_o,
    output logic error_o,  // For debug
    output logic w_rn_o  // Write = 1 and read = 0
);

  always_comb begin
    addr_o = addr_i;
    value_proc_o = '0;
    value_ram_o = '0;
    w_rn_o = 0;
    error_o = 0;
    case (op_i)
      LSU_SW: begin
        value_ram_o = value_proc_i;
        w_rn_o = 1;
      end
      LSU_LW:  value_proc_o = value_ram_i;
      LSU_LH:  value_proc_o = {{16{value_ram_i[15]}}, value_ram_i[15:0]};  // Sign extension
      LSU_LHU: value_proc_o = {{16{1'b0}}, value_ram_i[15:0]};  // Zero extension
      LSU_LB:  value_proc_o = {{24{value_ram_i[7]}}, value_ram_i[7:0]};  // Sign extension
      LSU_LBU: value_proc_o = {{24{1'b0}}, value_ram_i[7:0]};  // Zero extension
      LSU_NOP: addr_o = '0;  // Return same address at 0
      default: error_o = 1;
    endcase
  end

endmodule

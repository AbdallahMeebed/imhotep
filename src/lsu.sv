// Load store unit
module lsu
  import imhotep_pkg::*;
(
    // Processor interface
    input logic [RAM_WIDTH - 1:0] addr_i,
    input op_lsu_e op_i,
    input logic [XLEN - 1:0] data_proc_i,
    output logic [XLEN - 1:0] data_proc_o,

    // RAM interface
    input logic [XLEN - 1:0] data_ram_i,
    output logic [XLEN - 1:0] data_ram_o,
    output logic [RAM_WIDTH - 1:0] addr_o,
    output logic [1:0] width_o,
    output logic w_rn_o,  // Write = 1 and read = 0
    output logic error_o  // For debug
);

  always_comb begin
    addr_o = addr_i;
    data_proc_o = '0;
    data_ram_o = '0;
    width_o = 2'b10;
    w_rn_o = 0;
    error_o = 0;
    case (op_i)
      LSU_SW: begin
        data_ram_o = data_proc_i;
        width_o = 2'b10;
        w_rn_o = 1;
      end
      LSU_SH: begin
        data_ram_o = data_proc_i;
        width_o = 2'b01;
        w_rn_o = 1;
      end
      LSU_SB: begin
        data_ram_o = data_proc_i;
        width_o = 2'b00;
        w_rn_o = 1;
      end
      LSU_LW:  data_proc_o = data_ram_i;
      LSU_LH:  data_proc_o = {{16{data_ram_i[15]}}, data_ram_i[15:0]};  // Sign extension
      LSU_LHU: data_proc_o = {{16{1'b0}}, data_ram_i[15:0]};  // Zero extension
      LSU_LB:  data_proc_o = {{24{data_ram_i[7]}}, data_ram_i[7:0]};  // Sign extension
      LSU_LBU: data_proc_o = {{24{1'b0}}, data_ram_i[7:0]};  // Zero extension
      LSU_NOP: addr_o = '0;  // Return same address at 0
      default: error_o = 1;
    endcase
  end

endmodule

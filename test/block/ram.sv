// External RAM, only for simulation
module ram
  import imhotep_pkg::*;
(
    input clk,
    input reset_n,
    input w_rn_i,  // Write = 1, Read = 0
    input logic [1:0] width_i,  // 00 for 1 byte, 01 for 2, 10 for 4
    input logic [XLEN - 1:0] data_i,
    input logic [RAM_WIDTH - 1 : 0] addr_i,
    output logic [XLEN - 1:0] data_o
);

  localparam longint N_ENTRY = 2 ** RAM_WIDTH;
  logic [7:0] storage[N_ENTRY];

  always_ff @(posedge clk or negedge reset_n) begin
    // Clear all the memory
    if (!reset_n) begin
      storage <= '{default: 'b0};
    end else begin
      if (w_rn_i) begin
        case (width_i)
          2'b00: storage[addr_i] <= data_i[7:0];
          2'b01: {storage[addr_i+1], storage[addr_i]} <= data_i[15:0];
          2'b10:
          {storage[addr_i + 3], storage[addr_i + 2],
          storage[addr_i + 1], storage[addr_i]} <= data_i[31:0];
          default: ;
        endcase
      end
    end
  end

  // Connected to decoder to get the values
  always_comb begin
    if (w_rn_i) data_o = '0;
    else begin
      case (width_i)
        2'b00: data_o = {24'b0, storage[addr_i]};
        2'b01: data_o = {16'b0, storage[addr_i+1], storage[addr_i]};
        2'b10: data_o = {storage[addr_i+3], storage[addr_i+2], storage[addr_i+1], storage[addr_i]};
        default: data_o = '0;
      endcase
    end
  end

endmodule

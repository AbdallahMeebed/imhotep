// General purpose registers
// 32 registers of length 32 bits

module register_file
  import imhotep_pkg::*;
(
    input clk,
    input reset_n,
    input [4:0] r1_addr_i,
    input [4:0] r2_addr_i,
    input [4:0] w_addr_i,  // w_addr is to write the result of operations with w_value
    output [31:0] r1_value_o,
    output [31:0] r2_value_o,
    input [31:0] w_value_i
);
  // Important note: writing to R0 does nothing, which will be used as default value for w_addr
  // if you don't want to write anything

  logic [31:0][XLEN - 1:0] bench;  // Main memory we have

  always_ff @(posedge clk or negedge reset_n) begin
    // Clear all the memory
    if (reset_n == 1'b0) begin
      bench <= '{default: 'b0};
    end else begin
      if (w_addr != 'b0) begin  // Wants to write to an address
        bench[w_addr] <= w_value;
      end
    end
  end

  // Connected to decoder to get the values
  assign r1_value = bench[r1_addr];
  assign r2_value = bench[r2_addr];

endmodule

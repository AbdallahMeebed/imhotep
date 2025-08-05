module scoreboard
  import imhotep_pkg::*;
(
    input logic clk,
    input logic reset_n,

    // Decoder interface
    input logic [RFADDR - 1:0] query_1_i,
    input logic [RFADDR - 1:0] query_2_i,
    input logic [RFADDR - 1:0] commit_i,
    output logic query_answer_1_o,
    output logic query_answer_2_o,

    // WB Interface
    input logic [RFADDR - 1:0] retire_i
);

  // 1 if register is in execute stage (avoid RAW hazards)
  logic [31:0] board;

  // Possible assertion: Can only commit if the query returned 0
  // Retired values must be committed beforehand
  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      board <= '0;
    end else begin
      // Case when rd is retired and committed at the same time (due to
      // writeback), priority is given to commit
      if (retire_i != '0) begin
        board[retire_i] <= 1'b1;
      end
      if (commit_i != '0 && commit_i != retire_i) begin
        board[commit_i] <= 1'b0;
      end
    end
  end

  assign query_answer_1_o = board[query_1_i];
  assign query_answer_2_o = board[query_2_i];

endmodule

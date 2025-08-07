`timescale 1ns / 1ps

module ram_tb
  import imhotep_pkg::*;
();

  logic clk, reset_n, w_rn_i;
  logic [1:0] width_i;  // 00 for 1 byte, 01 for 2, 10 for 4
  logic [XLEN - 1:0] data_i;
  logic [RAM_WIDTH - 1 : 0] addr_i;
  logic [XLEN - 1:0] data_o;

  ram u_ram (.*);

  // Clock
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  initial begin
    $monitor("time=%3d, w_rn=%h, width=%h, in=%h, out=%h, addr=%h", $time, w_rn_i, width_i, data_i,
             data_o, addr_i);

    // $display("Number: %d", 1<<6);
    reset_n = 1'b0;
    #10 reset_n = 1'b1;
    #10 addr_i = 16'h1000;
    data_i  = '1;
    width_i = 2'b00;
    w_rn_i  = 1'b1;

    #10 addr_i = 16'h1000;
    width_i = 2'b00;
    w_rn_i  = 1'b0;

    #10 addr_i = 16'h2000;
    data_i  = '1;
    width_i = 2'b01;
    w_rn_i  = 1'b1;

    #10 addr_i = 16'h2000;
    width_i = 2'b01;
    w_rn_i  = 1'b0;

    #10 addr_i = 16'h3000;
    data_i  = '1;
    width_i = 2'b10;
    w_rn_i  = 1'b1;

    #10 addr_i = 16'h3000;
    width_i = 2'b10;
    w_rn_i  = 1'b0;

    #10 addr_i = 16'h3000;
    data_i  = '0;
    width_i = 2'b01;
    w_rn_i  = 1'b1;

    #10 addr_i = 16'h3000;
    width_i = 2'b10;
    w_rn_i  = 1'b0;

    #1 $finish;
  end

endmodule

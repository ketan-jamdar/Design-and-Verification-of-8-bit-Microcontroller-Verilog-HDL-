`timescale 1ns / 1ps
// ---------- DMem (single definition) ----------
module Dmem_unit(
    input  logic clk,
    input  logic E,      // Enable port 
    input  logic WE,     // Write enable port
    input  logic [3:0] Addr, // Address port 
    input  logic [7:0] DI,   // Data input port
    output logic [7:0] DO    // Data output port
);
  // 256 x 8-bit data memory
  reg [7:0] data_mem [255:0];

  always @(posedge clk) begin
    if (E && WE)
      data_mem[Addr] <= DI;
  end

  assign DO = (E) ? data_mem[Addr] : 8'd0;
endmodule
`timescale 1ns / 1ps
// ---------- MUX1 (single definition) ----------
// Reused for both MUX1 and MUX2 usage (In1/In2 order in instances)
module MUX1_unit(
    input  logic [7:0] In1,
    input  logic [7:0] In2,
    input  logic Sel,
    output logic [7:0] Out
);
  assign Out = (Sel == 1'b1) ? In1 : In2;
endmodule


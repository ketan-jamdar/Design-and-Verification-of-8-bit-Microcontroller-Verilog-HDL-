`timescale 1ns / 1ps

// ---------- simple adder ----------
//for normally increment pc to access next location
module PC_Adder_unit(
    input  logic [7:0] In,
    output logic [7:0] Out
);
  assign Out = In + 8'd1;
endmodule

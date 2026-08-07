`timescale 1ns / 1ps
// ---------- PMem ----------
module PMem_unit(
  input  logic clk,
  input  logic E,         // Enable port
  input  logic [7:0] Addr,// Address port
  output logic [11:0] I,  // Instruction port
  
  // 3 special ports to load program to the memory
  input  logic LE,        // Load enable port 
  input  logic [7:0] LA,  // Load address port
  input  logic [11:0] LI  // Load instruction port
);
  reg [11:0] Prog_Mem [255:0];

  always @(posedge clk) begin
    if (LE)
      Prog_Mem[LA] <= LI;
  end

  assign I = (E) ? Prog_Mem[Addr] : 12'd0;
endmodule


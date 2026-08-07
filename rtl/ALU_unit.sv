`timescale 1ns / 1ps
// ---------- ALU ----------
module ALU_unit(
  input  logic [7:0] Operand1,
  input  logic [7:0] Operand2,
  input  logic E,
  input  logic [3:0] Mode,
  input  logic [3:0] CFlags,
  output logic [7:0] Out,
  output logic [3:0] Flags
);
  logic Z, S, O;
  logic CarryOut;
  logic [7:0] Out_ALU;

  always @(*) begin
    CarryOut = 1'b0;
    Out_ALU = Operand2;
    case (Mode)
      4'b0000: {CarryOut, Out_ALU} = Operand1 + Operand2;
      4'b0001: begin
         Out_ALU = Operand1 - Operand2;
         CarryOut = ~Out_ALU[7];
      end
      4'b0010: Out_ALU = Operand1;
      4'b0011: Out_ALU = Operand2;
      4'b0100: Out_ALU = Operand1 & Operand2;
      4'b0101: Out_ALU = Operand1 | Operand2;
      4'b0110: Out_ALU = Operand1 ^ Operand2;
      4'b0111: begin
         Out_ALU = Operand2 - Operand1;
         CarryOut = ~Out_ALU[7];
      end
      4'b1000: {CarryOut, Out_ALU} = Operand2 + 8'h1;
      4'b1001: begin
         Out_ALU = Operand2 - 8'h1;
         CarryOut = ~Out_ALU[7];
      end
      4'b1010: Out_ALU = (Operand2 << Operand1[2:0]) | (Operand2 >> Operand1[2:0]);
      4'b1011: Out_ALU = (Operand2 >> Operand1[2:0]) | (Operand2 << Operand1[2:0]);
      4'b1100: Out_ALU = Operand2 << Operand1[2:0];
      4'b1101: Out_ALU = Operand2 >> Operand1[2:0];
      4'b1110: Out_ALU = Operand2 >>> Operand1[2:0];
      4'b1111: begin
         Out_ALU = 8'h0 - Operand2;
         CarryOut = ~Out_ALU[7];
      end
      default: Out_ALU = Operand2;
    endcase
  end

  assign O = Out_ALU[7] ^ Out_ALU[6];
  assign Z = (Out_ALU == 8'h00) ? 1'b1 : 1'b0;
  assign S = Out_ALU[7];
  assign Flags = {Z, CarryOut, S, O};
  assign Out = Out_ALU;

endmodule
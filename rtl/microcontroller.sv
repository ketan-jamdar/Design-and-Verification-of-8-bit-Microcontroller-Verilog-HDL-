`timescale 1ns / 1ps

module microcontroller(
    input  logic clk,
    input  logic rst
    );
  // FSM states
  parameter LOAD  = 2'b00,
            FETCH = 2'b01,
            DECODE= 2'b10,
            EXECUTE=2'b11;

  reg [1:0] current_state, next_state;
  reg [11:0] program_mem[9:0];
  reg load_done;
  reg [7:0] load_addr;
  wire [11:0] load_instr;

  // registers / pipeline regs
  reg [7:0] PC, DR, Acc;
  reg [11:0] IR;
  reg [3:0] SR;

  // enables / clears
  wire PC_E, Acc_E, SR_E, IR_E, DR_E;
  reg  PC_clr, Acc_clr, SR_clr, DR_clr, IR_clr;

  // Updated outputs / wires
  wire [7:0] PC_updated, DR_updated;
  wire [11:0] IR_updated;
  wire [3:0] SR_updated;

  // control signals
  wire PMem_E, DMem_E, DMem_WE, ALU_E, PMem_LE, MUX1_Sel, MUX2_Sel;
  wire [3:0] ALU_Mode;
  wire [7:0] Adder_Out;
  wire [7:0] ALU_Out, ALU_Oper2;

  // LOAD instruction memory file (for simulation)
  initial begin
    $readmemb("program.mem", program_mem, 0, 9);
  end

  // Instantiate ALU (uses rst as rst_n)
  ALU_unit A(
      .Operand1(Acc),
      .Operand2(ALU_Oper2),
      .E(ALU_E),
      .Mode(ALU_Mode),
      .CFlags(SR),
      .Out(ALU_Out),
      .Flags(SR_updated)
  );

  // MUX2: select between IR[7:0] and DR for ALU operand2
  MUX1_unit M2(
      .In1(DR),
      .In2(IR[7:0]),
      .Sel(MUX2_Sel),
      .Out(ALU_Oper2)
  );

  // Data Memory (one module only)
  Dmem_unit D0(
      .clk(clk),
      .E(DMem_E),
      .WE(DMem_WE),
      .Addr(IR[3:0]),
      .DI(ALU_Out),
      .DO(DR_updated)
  );

  // Program memory (PMem) - has load ports
  PMem_unit P0(
      .clk(clk),
      .E(PMem_E),
      .Addr(PC),
      .I(IR_updated),
      .LE(PMem_LE),
      .LA(load_addr),
      .LI(load_instr)
  );

  // PC adder: increment PC by 1
  PC_Adder_unit A0(.In(PC), .Out(Adder_Out));

  // MUX1: choose between IR[7:0] (branch/jump) or adder out
  MUX1_unit M1(
      .In1(Adder_Out),
      .In2(IR[7:0]),
      .Sel(MUX1_Sel),
      .Out(PC_updated)
  );

  // Control logic
  Control_Logic_Unit C0(
      .stage(current_state),
      .IR(IR),
      .SR(SR),
      .PC_E(PC_E),
      .Acc_E(Acc_E),
      .SR_E(SR_E),
      .IR_E(IR_E),
      .DR_E(DR_E),
      .PMem_E(PMem_E),
      .DMem_E(DMem_E),
      .DMem_WE(DMem_WE),
      .ALU_E(ALU_E),
      .MUX1_Sel(MUX1_Sel),
      .MUX2_Sel(MUX2_Sel),
      .PMem_LE(PMem_LE),
      .ALU_Mode(ALU_Mode)
  );

  // LOAD sequencing to push data from program_mem[] into PMem via load ports
  always @(posedge clk) begin
    if (rst) begin
      load_addr <= 8'd0;
      load_done <= 1'b0;
    end else if (PMem_LE == 1) begin
      load_addr <= load_addr + 8'd1;
      if (load_addr == 8'd9) begin
        load_addr <= 8'd0;
        load_done <= 1'b1;
      end else begin
        load_done <= 1'b0;
      end
    end
  end

  assign load_instr = program_mem[load_addr];

  // FSM: next state register
  always @(posedge clk) begin
    if (rst)
      current_state <= LOAD;
    else
      current_state <= next_state;
  end

  // FSM combinational next state and clears
  always @(*) begin
    PC_clr = 0;
    Acc_clr = 0;
    SR_clr = 0;
    DR_clr = 0;
    IR_clr = 0;

    case (current_state)
      LOAD: begin
        if (load_done == 1) begin
          next_state = FETCH;
          PC_clr = 1;
          Acc_clr = 1;
          SR_clr = 1;
          DR_clr = 1;
          IR_clr = 1;
        end else
          next_state = LOAD;
      end

      FETCH: next_state = DECODE;
      DECODE: next_state = EXECUTE;
      EXECUTE: next_state = FETCH;
      default: next_state = LOAD;
    endcase
  end

  // programmer-visible registers (PC, Acc, SR)
  always @(posedge clk) begin
    if (rst) begin
      PC  <= 8'd0;
      Acc <= 8'd0;
      SR  <= 4'd0;
    end else begin
      if (PC_E == 1'b1)
        PC <= PC_updated;
      else if (PC_clr == 1)
        PC <= 8'd0;

      if (Acc_E == 1'b1)
        Acc <= ALU_Out;
      else if (Acc_clr == 1)
        Acc <= 8'd0;

      if (SR_E == 1'b1)
        SR <= SR_updated;
      else if (SR_clr == 1)
        SR <= 4'd0;
    end
  end

  // programmer-invisible registers (DR, IR)
  always @(posedge clk) begin
    if (DR_E == 1'b1)
      DR <= DR_updated;
    else if (DR_clr == 1)
      DR <= 8'd0;

    if (IR_E == 1'b1)
      IR <= IR_updated;
    else if (IR_clr == 1)
      IR <= 12'd0;
  end

endmodule // MicroController





// Header to define common signals between blocks
package imhotep_pkg;

  parameter int XLEN = 32;  // Address space length
  parameter int RAM_WIDTH = 16;
  localparam int RFADDR = 5;
  localparam int RFLEN = 2 ** RFADDR;

  parameter int ALU_OP_WIDTH = 4;
  typedef enum logic [ALU_OP_WIDTH - 1:0] {
    ALU_ADD,
    ALU_SUB,
    ALU_AND,
    ALU_XOR,
    ALU_SLT,
    ALU_SLTU,
    ALU_JMPR,  // Add and make LSB = 0
    ALU_OR,
    ALU_SLL,
    ALU_SRA,
    ALU_NOP
  } op_alu_e;


  parameter int LSU_OP_WIDTH = 4;
  typedef enum logic [LSU_OP_WIDTH-1:0] {
    LSU_SW,
    LSU_SH,   // TODO
    LSU_SB,   // TODO
    LSU_LW,
    LSU_LH,
    LSU_LHU,
    LSU_LB,
    LSU_LBU,
    LSU_NOP
  } op_lsu_e;

  parameter int CSR_WIDTH = 3;
  typedef enum logic [CSR_WIDTH - 1:0] {
    CSR_BEQ,
    CSR_BNE,
    CSR_BLT,
    CSR_BLTU,
    CSR_BGE,
    CSR_BGEU,
    CSR_JMP,
    CSR_NOP
  } op_csr_e;

  parameter int WB_MUX_WIDTH = 2;
  typedef enum logic [WB_MUX_WIDTH - 1 : 0] {
    WB_SEL_ALU,
    WB_SEL_LSU,
    WB_SEL_PC_INC
  } wb_mux_e;

  localparam logic [6:0] OPCODE_OP = 7'h33;
  localparam logic [6:0] OPCODE_OPIMM = 7'h13;
  localparam logic [6:0] OPCODE_STORE = 7'h23;
  localparam logic [6:0] OPCODE_LOAD = 7'h03;
  localparam logic [6:0] OPCODE_BRANCH = 7'h63;
  localparam logic [6:0] OPCODE_JALR = 7'h67;
  localparam logic [6:0] OPCODE_JAL = 7'h6f;

  // TODO
  localparam logic [6:0] OPCODE_FENCE = 7'h0f;
  localparam logic [6:0] OPCODE_AUIPC = 7'h17;
  localparam logic [6:0] OPCODE_LUI = 7'h37;
  localparam logic [6:0] OPCODE_SYSTEM = 7'h73;

endpackage


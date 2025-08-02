// Header to define common signals between blocks
package imhotep_pkg;
  parameter int ALU_WIDTH = 3;
  typedef enum logic [ALU_WIDTH - 1:0] {
    ALU_ADD,
    ALU_SUB,
    ALU_AND,
    ALU_XOR,
    ALU_SLT,
    ALU_JMPR,  // Add and make LSB = 0
    // ALU_UNKNOWN, // Output needs to be something
    ALU_OR
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
    LSU_NOP   // Do nothing
  } op_lsu_e;

  parameter int MUX_WIDTH = 2;
  typedef enum logic [MUX_WIDTH - 1:0] {
    MUX_SEL_R,
    MUX_SEL_IMM,
    MUX_SEL_PC,
    MUX_SEL_WB    // Not implement yet
  } decod_mux_sel_e;

  parameter int CSR_WIDTH = 3;
  typedef enum logic [CSR_WIDTH - 1:0] {
    CSR_BEQ,
    CSR_BNE,
    CSR_BLT,
    CSR_BLTU,
    CSR_BGE,
    CSR_BGEU,
    CSR_JMP,   // Always 1
    CSR_NOP
  } op_csr_e;

  parameter int LSU_WIDTH = 16;

  parameter int MUX_EXEC_WIDTH = 2;
  typedef enum logic [MUX_EXEC_WIDTH - 1:0] {
    SEL_ALU,
    SEL_LSU,
    SEL_PC_INC
  } exec_mux_sel_e;

  // The operations that are going to be implemented
  parameter logic [6:0] OPCODE_OP = 7'h33;
  parameter logic [6:0] OPCODE_OPIMM = 7'h13;
  parameter logic [6:0] OPCODE_STORE = 7'h23;
  parameter logic [6:0] OPCODE_LOAD = 7'h03;
  parameter logic [6:0] OPCODE_BRANCH = 7'h63;
  parameter logic [6:0] OPCODE_JALR = 7'h67;
  parameter logic [6:0] OPCODE_JAL = 7'h6f;

endpackage


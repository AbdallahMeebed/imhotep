// Decode instructions
module decoder
  import imhotep_pkg::*;
(
    input [XLEN - 1:0] instr_i,

    // ALU Interface
    output op_alu_e op_alu_o,
    output [XLEN - 1:0] alu_in1_o,
    output [XLEN - 1:0] alu_in2_o,

    // LSU Interface
    output op_lsu_e op_lsu_o,

    // CSR Interface
    output op_csr_e op_csr_o,

    // RF Interface
    input  logic [RFLEN - 1 : 0] r1_data_i,
    input  logic [RFLEN - 1 : 0] r2_data_i,
    output logic [ RFADDR - 1:0] r1_addr_o,
    output logic [ RFADDR - 1:0] r2_addr_o,
    output logic [ RFADDR - 1:0] rd_addr_o,

    output logic err_o,
    output logic stall_o,  // For error detection (debug for now)
    output logic [31:0] immediate_o
);

  // Cycle to select operation
  always_comb begin
    // Default case so we don't latch (rd always same place etc.)
    // {r1_addr, r2_addr, immediate, rd_addr, err} = '0;
    {immediate_o, err_o, stall_o} = '0;
    rd_addr_o = instr[11:7];
    r1_addr_o = instr[19:15];
    r2_addr_o = instr[24:20];
    op_alu_o = ALU_NOP;
    op_lsu_o = LSU_NOP;
    op_csr_o = CSR_NOP;

    case (instr[6:0])
      OPCODE_OP: begin
        case (instr[14:12])
          // For ADD need to check if it's sub at instr[30]
          3'b000: op_alu_o = (instr[30]) ? ALU_SUB : ALU_ADD;
          3'b111: op_alu_o = ALU_AND;
          3'b110: op_alu_o = ALU_OR;
          3'b100: op_alu_o = ALU_XOR;
          3'b010: op_alu_o = ALU_SLT;
          default: begin
            rd_addr_o = '0;  // prevent any write because we don't recognize the operation
            err_o = 1'b1;
          end
        endcase
      end

      OPCODE_OPIMM: begin
        immediate_o = {{20{instr[31]}}, instr[31:20]};  // Sign extension
        case (instr[14:12])
          // For ADD need to check if it's sub at instr[30]
          3'b000: op_alu_o = ALU_ADD;
          3'b111: op_alu_o = ALU_AND;
          3'b110: op_alu_o = ALU_OR;
          3'b100: op_alu_o = ALU_XOR;
          3'b010: op_alu_o = ALU_SLT;
          default: begin
            rd_addr_o = '0;  // prevent any write because we don't recognize the operation
            err_o = 1'b1;
          end
        endcase
      end

      // Decode load store instructions
      OPCODE_LOAD: begin
        immediate_o = {{20{instr[31]}}, instr[31:20]};  // Sign extension
        case (instr[14:12])
          3'b000: op_lsu_o = LSU_LB;
          3'b001: op_lsu_o = LSU_LH;
          3'b010: op_lsu_o = LSU_LW;
          3'b100: op_lsu_o = LSU_LBU;
          3'b101: op_lsu_o = LSU_LHU;
          default: begin
            rd_addr_o = '0;
            err_o = 1'b1;
          end
        endcase
      end

      OPCODE_STORE: begin
        immediate_o = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        rd_addr_o   = '0;  // Avoid writes because rd not specified
        case (instr[14:12])
          3'b000: op_lsu_o = LSU_SB;
          3'b001: op_lsu_o = LSU_SH;
          3'b010: op_lsu_o = LSU_SW;
          default: begin
            rd_addr_o = '0;
            err_o = 1'b1;
          end
        endcase
      end

      OPCODE_JAL: begin
        immediate_o = {
          {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0
        };  // Sign extension
        op_alu_o = ALU_ADD;
        op_csr_o = CSR_JMP;
        stall_o = 1'b1;  // To add bubble
      end

      OPCODE_JALR: begin
        immediate_o = {{20{instr[31]}}, instr[31:20]};  // Sign extension
        op_alu_o = ALU_JMPR;
        op_csr_o = CSR_JMP;
        stall_o = 1'b1;  // To add bubble
      end

      OPCODE_BRANCH: begin
        stall_o = 1'b1;  // To add bubble
        immediate_o = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
        op_alu_o = ALU_ADD;  // NEEDS TO ALSO TAKE RS1 AND RS2 for the jump block
        rd_addr_o = '0;  // Avoid writes because rd not specified
        case (instr[14:12])
          3'b000: op_csr_o = CSR_BEQ;
          3'b001: op_csr_o = CSR_BNE;
          3'b100: op_csr_o = CSR_BLT;
          3'b101: op_csr_o = CSR_BGE;
          3'b110: op_csr_o = CSR_BLTU;
          3'b111: op_csr_o = CSR_BGEU;
          default: begin
            rd_addr_o = '0;
            err_o = 1'b1;
          end
        endcase
      end
      default: err_o = 1'b1;
    endcase
  end

endmodule

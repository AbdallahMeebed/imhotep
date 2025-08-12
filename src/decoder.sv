// Decode instructions
module decoder
  import imhotep_pkg::*;
(
    // Fetch interface
    input logic [31:0] instr_i,
    input logic [31:0] pc_i,

    // Control signals
    output wb_mux_e wb_mux,

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

    // Scoreboard interface
    output logic [RFADDR - 1:0] query_1_o,
    output logic [RFADDR - 1:0] query_2_o,
    output logic [RFADDR - 1:0] commit_o,
    input logic query_answer_1_i,
    input logic query_answer_2_i,

    output logic err_o,
    output logic stall_o  // For error detection (debug for now)
);

  logic [31:0] immediate;

  // Cycle to select operation
  always_comb begin
    // Default case so we don't latch (rd always same place etc.)
    rd_addr_o = instr_i[11:7];
    r1_addr_o = instr_i[19:15];
    r2_addr_o = instr_i[24:20];
    op_alu_o = ALU_NOP;
    op_lsu_o = LSU_NOP;
    op_csr_o = CSR_NOP;
    wb_mux = WB_SEL_ALU;
    alu_in1_o = '0;
    alu_in2_o = '0;
    immediate = '0;
    err_o = '0;

    case (instr_i[6:0])
      OPCODE_OP: begin
        case (instr_i[14:12])
          // For ADD need to check if it's sub at instr[30]
          3'b000: op_alu_o = (instr_i[30]) ? ALU_SUB : ALU_ADD;
          3'b001: op_alu_o = ALU_SLL;
          3'b010: op_alu_o = ALU_SLT;
          3'b011: op_alu_o = ALU_SLTU;
          3'b100: op_alu_o = ALU_XOR;
          3'b101: op_alu_o = (instr_i[30]) ? ALU_SRA : ALU_SRL;
          3'b110: op_alu_o = ALU_OR;
          3'b111: op_alu_o = ALU_AND;
          default: begin
            rd_addr_o = '0;  // prevent any write because we don't recognize the operation
            err_o = 1'b1;
          end
        endcase

        alu_in1_o = r1_data_i;
        alu_in2_o = r2_data_i;
      end

      OPCODE_OPIMM: begin
        immediate = {{(XLEN - 1) {instr_i[31]}}, instr_i[31:20]};  // Sign extension
        r2_addr_o = '0;
        case (instr_i[14:12])
          3'b000: op_alu_o = ALU_ADD;
          3'b001: begin
            op_alu_o  = ALU_SLL;
            immediate = {{(XLEN - 1) {1'b0}}, instr_i[25:20]};
          end
          3'b010: op_alu_o = ALU_SLT;
          3'b011: op_alu_o = ALU_SLTU;
          3'b100: op_alu_o = ALU_XOR;
          3'b101: begin
            op_alu_o  = (instr_i[30]) ? ALU_SRA : ALU_SRL;
            immediate = {{(XLEN - 1) {1'b0}}, instr_i[25:20]};
          end
          3'b110: op_alu_o = ALU_OR;
          3'b111: op_alu_o = ALU_AND;
          default: begin
            rd_addr_o = '0;  // prevent any write because we don't recognize the operation
            err_o = 1'b1;
          end

        endcase

        alu_in1_o = r1_data_i;
        alu_in2_o = immediate;

        r2_addr_o = '0;  // Disable scoreboard query
      end

      // Decode load store instructions
      OPCODE_LOAD: begin
        immediate = {{20{instr_i[31]}}, instr_i[31:20]};  // Sign extension
        r2_addr_o = '0;
        case (instr_i[14:12])
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

        op_alu_o  = ALU_ADD;
        alu_in1_o = r1_data_i;
        alu_in2_o = immediate;

        r2_addr_o = '0;  // Disable scoreboard query
      end

      OPCODE_STORE: begin
        immediate = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
        rd_addr_o = '0;  // Avoid writes because rd not specified
        case (instr_i[14:12])
          3'b000: op_lsu_o = LSU_SB;
          3'b001: op_lsu_o = LSU_SH;
          3'b010: op_lsu_o = LSU_SW;
          default: begin
            rd_addr_o = '0;
            err_o = 1'b1;
          end
        endcase

        op_alu_o  = ALU_ADD;
        alu_in1_o = r1_data_i;
        alu_in2_o = immediate;
      end

      OPCODE_JAL: begin
        immediate = {
          {12{instr_i[31]}}, instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0
        };  // Sign extension
        op_alu_o = ALU_ADD;
        op_csr_o = CSR_JMP;
        wb_mux = WB_SEL_PC_INC;

        alu_in1_o = pc_i;
        alu_in2_o = immediate;
        // stall_o = 1'b1;  // To add bubble
      end

      OPCODE_JALR: begin
        immediate = {{20{instr_i[31]}}, instr_i[31:20]};  // Sign extension
        op_alu_o  = ALU_JMPR;
        op_csr_o  = CSR_JMP;
        // stall_o   = 1'b1;  // To add bubble

        alu_in1_o = pc_i;
        alu_in2_o = immediate;
      end

      OPCODE_BRANCH: begin
        // stall_o   = 1'b1;  // To add bubble
        immediate = {{20{instr_i[31]}}, instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};
        rd_addr_o = '0;  // Avoid writes because rd not specified
        case (instr_i[14:12])
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

        op_alu_o  = ALU_ADD;
        alu_in1_o = pc_i;
        alu_in2_o = immediate;
      end
      default: err_o = 1'b1;
    endcase
  end

  // Stall logic
  assign stall_o   = query_answer_1_i | query_answer_2_i;
  assign query_1_o = r1_addr_o;
  assign query_2_o = r2_addr_o;
  assign commit_o  = rd_addr_o & (~stall_o);

endmodule

module decode (
    input logic [31:0] instr_i,

    output logic [4:0] op,
    output logic [31:0] imm_i_o,
    output logic [31:0] imm_s_o,
    output logic [31:0] imm_b_o
);

    import cpu_pkg::*;

    // sign extend the immediates
    assign imm_i_o = {{20{instr_i[31]}}, instr_i[31:20]};
    assign imm_s_o = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
    assign imm_b_o = {{19{instr_i[31]}}, instr_i[31], instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};

    // decodes the opcodes, funct3, and funct7
    always_comb begin
        case(instr_i[6:0])
            7'b0010011: op = ADDI;
            7'b1110011: op = instr_i[20] ? EBREAK : NOP;
            7'b0110011: begin
                case(instr_i[14:12])
                    3'b000: op = instr_i[30] ? SUB : ADD;
                    3'b001: op = SLL;
                    3'b101: op = SRL;
                    default: op = NOP;
                endcase
            end
            7'b0000011: op = LOAD;
            7'b0100011: op = STORE;
            7'b1100011: op = BEQ;
            default: op = NOP;
        endcase
    end

endmodule

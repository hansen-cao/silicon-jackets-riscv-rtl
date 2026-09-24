module control (
    input logic clk_i,
    input logic rst_i,
    input logic en_i,

    input logic instr_vld_i,
    input logic [31:0] instr_i,

    input logic [31:0] current_pc,

    input logic dsram_rready_i,
    input logic [31:0] dsram_rdata_i,
    input logic [31:0] rs1_data_i,
    input logic [31:0] rs2_data_i,

    output logic [31:0] dsram_rdata_reg_o,
    output logic dsram_en_o,
    output logic dsram_write_en_o,

	output logic [4:0] rs1_addr_o,
    output logic [4:0] rs2_addr_o,
    output logic [4:0] rd_addr_o,
    output logic rd_write_en_o,

    output logic halted_o,
    output logic stall_core_o,
    output logic branch_vld_o,
    output logic [4:0] op,
    output logic [31:0] pc_reg_o,

    output logic [31:0] imm_i_o,
    output logic [31:0] imm_s_o,
    output logic [31:0] imm_b_o
);

    // enum the different states
    typedef enum logic [2:0] {
        FETCH,
        DECODE,
        EXECUTE,
        WRITEBACK,
        MEM,
        BRANCH
    } states;

    states state, next_state;

    import cpu_pkg::*;

    logic [31:0] instr_reg;
    logic halted;

    assign stall_core_o = (state != FETCH & state != BRANCH) | halted_o | ~en_i;
    assign rs1_addr_o = instr_reg[19:15];
    assign rs2_addr_o = instr_reg[24:20];
    assign rd_addr_o = instr_reg[11:7];

    // Decode module
    decode u_decode (
        .instr_i(instr_reg),
        .op(op),
        .imm_i_o(imm_i_o),
        .imm_s_o(imm_s_o),
        .imm_b_o(imm_b_o)
    );

    // FSM
    always_comb begin
        rd_write_en_o = 1'b0;
        dsram_en_o = 1'b0;
        dsram_write_en_o = 1'b0;
        halted = 1'b0;
        branch_vld_o = 1'b0;
        next_state = state;

        case(state)
            FETCH: next_state = instr_vld_i ? DECODE : FETCH;
            DECODE: next_state = EXECUTE;
            EXECUTE: begin
                case(op)
                    NOP: next_state = FETCH;
                    EBREAK: begin
                        halted = 1'b1;
                        next_state = EXECUTE;
                    end
                    LOAD: next_state = MEM;
                    STORE: next_state = MEM;
                    BEQ: next_state = BRANCH;
                    default: next_state = WRITEBACK;
                endcase
            end
            WRITEBACK: begin
                case(op)
                    ADDI: rd_write_en_o = 1'b1;
                    ADD: rd_write_en_o = 1'b1;
                    SUB: rd_write_en_o = 1'b1;
                    SLL: rd_write_en_o = 1'b1;
                    SRL: rd_write_en_o = 1'b1;
                    LOAD: rd_write_en_o = 1'b1;
                    default: rd_write_en_o = 1'b0;
                endcase
                next_state = FETCH;
            end
            MEM: begin
                if (dsram_rready_i) next_state = WRITEBACK;
                else begin
                    next_state = MEM;

                    case(op)
                        LOAD: begin
                            dsram_en_o = 1'b1;
                            dsram_write_en_o = 1'b0;
                        end
                        STORE: begin
                            dsram_en_o = 1'b1;
                            dsram_write_en_o = 1'b1;
                        end
                        default: begin
                            dsram_en_o = 1'b0;
                            dsram_write_en_o = 1'b0;
                        end
                    endcase
                end
            end
            BRANCH: begin
                branch_vld_o = 1'b1;

                if (instr_i && (rs1_data_i != rs2_data_i)) next_state = DECODE;
                else next_state = FETCH;
            end
            default: next_state = FETCH;
        endcase
    end

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            halted_o <= 1'b0;
            instr_reg <= 32'b0;
            pc_reg_o <= 32'b0;
            state <= FETCH;
        end else begin
            state <= next_state;

            if (state == EXECUTE) begin
                halted_o <= halted;
            end else if (state == FETCH) begin
                if (instr_vld_i) begin
                    instr_reg <= instr_i;
                    pc_reg_o <= current_pc;
                end
            end else if (state == MEM) begin
                if (dsram_rready_i) dsram_rdata_reg_o <= dsram_rdata_i;
            end else if (state == BRANCH) begin
                if (instr_vld_i && (rs1_data_i != rs2_data_i)) begin
                    instr_reg <= instr_i;
                    pc_reg_o <= current_pc;
                end
            end
        end
    end

endmodule
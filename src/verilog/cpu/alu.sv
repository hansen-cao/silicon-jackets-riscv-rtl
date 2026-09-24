module alu (
    input logic [4:0] op,
    input logic [31:0] pc_i,
    input logic [31:0] instr_i,
    input logic [31:0] imm_i_i,
    input logic [31:0] imm_s_i,
    input logic [31:0] imm_b_i,

    input logic [31:0] rs1_data_i,
    input logic [31:0] rs2_data_i,
    input logic [31:0] dsram_rdata_i,

    output logic [9:0] dsram_addr_o,
    output logic [31:0] dsram_wdata_o,
    output logic [31:0] rd_data_o,

    output logic [9:0] branch_trgt_o,
    output logic branch_taken_o
);

    import cpu_pkg::*;

    logic [31:0] byte_addr;

    always_comb begin
        rd_data_o = 32'b0;
        byte_addr = 32'b0;
        dsram_addr_o = 10'b0;
        dsram_wdata_o = 32'b0;
        branch_trgt_o = 10'b0;
        branch_taken_o = 1'b0;

        case(op)
            ADDI: rd_data_o = rs1_data_i + imm_i_i;
            ADD: rd_data_o = rs1_data_i + rs2_data_i;
            SUB: rd_data_o = rs1_data_i - rs2_data_i;
            SLL: rd_data_o = rs1_data_i << rs2_data_i[4:0];
            SRL: rd_data_o = rs1_data_i >> rs2_data_i[4:0];
            LOAD: begin
                byte_addr = rs1_data_i + imm_i_i;
                // converts byte address to word address
                dsram_addr_o = byte_addr[11:2];
                rd_data_o = dsram_rdata_i;
            end
            STORE: begin
                byte_addr = rs1_data_i + imm_s_i;
                // converts byte address to word address
                dsram_addr_o = byte_addr[11:2];
                dsram_wdata_o = rs2_data_i;
            end
            BEQ: begin
                if (rs1_data_i == rs2_data_i) begin
                    branch_trgt_o = (pc_i + imm_b_i) >> 2;
                    branch_taken_o = 1'b1;
                end
            end
            default: ; // all outputs already defaulted above
        endcase
    end

endmodule

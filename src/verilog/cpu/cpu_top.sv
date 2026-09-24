// SYSTEM HEADER,
// SiliconJackets Fall26 Digital Design Onboarding Project
// In cpu_top.sv, I instantiated and connected my control and ALU modules within the supplied top-level scaffold.
// My instruction decoder is instantiated inside the control module.
// END SYSTEM HEADER

module cpu_top (
	input logic clk_i,
	input logic rst_i,
	input logic en_i,
	
	output logic halted_o,
	
	output logic [31:0] reg_crossbar_o [0:31],
	
	output logic 	    isram_en_o,
	output logic [9:0]  isram_addr_o,
	input  logic [31:0] isram_rdata_i,
	input  logic 	    isram_rready_i,

	output logic 		dsram_en_o,
	output logic 		dsram_write_en_o,
	output logic [9:0]  dsram_addr_o,
    output logic [31:0] dsram_wdata_o,
	input  logic [31:0] dsram_rdata_i,
	input  logic 	    dsram_rready_i

);
	
	import cpu_pkg::*;
	
	// === Signal Declarations === //
	logic stall_core;

	// Fetch
	logic [31:0] instr;	
	logic [31:0] current_pc;
	logic instr_vld;
	logic branch_vld;
	logic [9:0] branch_trgt;	
	logic branch_taken;
	
	// === Instruction Fetch === //
	// certain ports are tied off bc they depend on modulees you need to implement.
	fetch u_fetch (
		.clk_i(clk_i),
		.rst_i(rst_i),
		.en_i(en_i),
		.stall_core_i(stall_core),
		.isram_en_o(isram_en_o),
		.isram_addr_o(isram_addr_o),
		.isram_rdata_i(isram_rdata_i),
		.isram_rready_i(isram_rready_i),
		.instr_o(instr),
		.pc_o(current_pc),
		.instr_vld_o(instr_vld),
		.branch_vld_i(branch_vld),
		.branch_trgt_i(branch_trgt),
		.branch_taken_i(branch_taken)
	);

	// Register
	logic [4:0] rs1_addr_i;
    logic [4:0] rs2_addr_i;
    logic [31:0] rs1_data_o;
    logic [31:0] rs2_data_o;
    logic rd_write_en_i;
    logic [4:0] rd_addr_i;
    logic [31:0] rd_data_i;
    logic [31:0] reg_values_o [0:31];

	// TODO: DO THIS FIRST, instantiate our Register File//
	reg_file u_reg (
		.clk_i(clk_i),
		.rst_i(rst_i),
		.rs1_addr_i(rs1_addr_i),
		.rs2_addr_i(rs2_addr_i),
		.rs1_data_o(rs1_data_o),
		.rs2_data_o(rs2_data_o),
		.rd_write_en_i(rd_write_en_i),
		.rd_addr_i(rd_addr_i),
		.rd_data_i(rd_data_i),
		.reg_values_o(reg_values_o)
	);

	// Disconnect this once you instantiate reg_file and connect reg_file's output to it instead
	assign reg_crossbar_o = reg_values_o;

	// instantiate the other modules you make here//
	// Control module
	logic [4:0] op;
	logic [31:0] imm_i;
	logic [31:0] imm_s;
	logic [31:0] imm_b;
	logic [31:0] dsram_rdata_reg;
	logic [31:0] pc_reg;

	control u_control (
		.clk_i(clk_i),
		.rst_i(rst_i),
		.en_i(en_i),
		.instr_vld_i(instr_vld),
		.instr_i(instr),
		.current_pc(current_pc),
		.dsram_rready_i(dsram_rready_i),
		.dsram_rdata_i(dsram_rdata_i),
		.rs1_data_i(rs1_data_o),
		.rs2_data_i(rs2_data_o),
		.dsram_rdata_reg_o(dsram_rdata_reg),
		.dsram_en_o(dsram_en_o),
		.dsram_write_en_o(dsram_write_en_o),
		.rs1_addr_o(rs1_addr_i),
		.rs2_addr_o(rs2_addr_i),
		.rd_addr_o(rd_addr_i),
		.rd_write_en_o(rd_write_en_i),
		.halted_o(halted_o),
		.stall_core_o(stall_core),
		.branch_vld_o(branch_vld),
		.op(op),
		.pc_reg_o(pc_reg),
		.imm_i_o(imm_i),
		.imm_s_o(imm_s),
		.imm_b_o(imm_b)
	);

	// alu module
	alu u_alu (
		.op(op),
		.pc_i(pc_reg),
		.instr_i(instr),
		.imm_i_i(imm_i),
		.imm_s_i(imm_s),
		.imm_b_i(imm_b),
		.rs1_data_i(rs1_data_o),
		.rs2_data_i(rs2_data_o),
		.dsram_rdata_i(dsram_rdata_reg),
		.dsram_addr_o(dsram_addr_o),
		.dsram_wdata_o(dsram_wdata_o),
		.rd_data_o(rd_data_i),
		.branch_trgt_o(branch_trgt),
		.branch_taken_o(branch_taken)
	);

endmodule

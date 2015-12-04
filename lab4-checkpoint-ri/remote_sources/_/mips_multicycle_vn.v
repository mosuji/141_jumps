`include "alu_defines.v"
`include "mips_defines.v"
`include "mips_multicycle_defines.v"
`include "mips_memory_space_defines.v"
//`define VERBOSE
`default_nettype none
`timescale 1ns/1ps
/*
	a version of the mips multicycle module with von Nuemann architecture
*/
module mips_multicycle_vn(clk, rst, ena, mem_addr, mem_rd_data, mem_wr_data, mem_wr_ena, PC, full_register_file);

parameter N = 32;

input wire clk, rst, ena;

`include "mips_helper.v"

/* ---- instantiate main modules ---- */
// the following are signals that are critical for the operation of your CPU
//   note: these are all reg type so that you can easily drive combinational logic 
//         through always@(*) blocks.  Not all of these need to be sequential.
reg [3:0] state, next_state;  //state is register, next_state driven comb.
output reg [31:0] PC; //the program counter

//memory signals
output reg [N-1:0] mem_addr, mem_wr_data;
reg [N-1:0] mem_wr_addr, mem_rd_addr;
input wire [N-1:0] mem_rd_data;
output reg mem_wr_ena;
// CUT<<<
// data memory signals are an artifact of an earlier Harvard-architecture implementation, 
// but I found it useful to abstract away fetch instruction signals from 
// general purpose memory IO.  The following comb. logic is OPTIONAL - you could also 
// just drive the mem_* signals above directly
reg [N-1:0] dmem_wr_addr, dmem_rd_addr; 
reg dmem_wr_ena;
always @(*) begin
	if( (state == `S_FETCH1) || (state == `S_FETCH2) ) begin
		mem_addr = PC; 
		mem_wr_ena = 0;
	end
	else begin //assume data access
		mem_wr_ena = dmem_wr_ena;
		mem_addr  = dmem_wr_ena ? dmem_wr_addr : dmem_rd_addr;
	end
end
//>>>
// the following are signals that should prove helpful in implementing your CPU
// but are not strictly required.  Feel free to modify/disregard these if your 
// particular implementation differs
reg [31:0]   next_PC, last_PC; //next_PC is comb., last_PC is a fairly useful register that stores the last succesful PC value
reg PC_ena; //enables the PC to be written
//non-architectural registers
reg IR_ena;
reg [31:0] IR; //holds the current instruction
reg [31:0] DR; //holds the value read out of the data memory
reg [31:0] reg_A, reg_B; //register file read data registers
reg [31:0] alu_last_result, exec_result; 
reg [31:0] instruction_count; // for debugging
reg [9:0] instruction_number;


/* the ALU */
reg  [N-1:0]  alu_src_a, alu_src_b;
wire [N-1:0] alu_result;
wire alu_equal, alu_zero, alu_overflow;
reg  [3:0] alu_op;
alu #(.N(N)) ALU (.x(alu_src_a), .y(alu_src_b), .z(alu_result), .op_code(alu_op), .zero(alu_zero), .equal(alu_equal), .overflow(alu_overflow));

/* register file */
reg reg_wr_ena;
reg [4:0] reg_rd_addr0, reg_rd_addr1, reg_wr_addr;
reg [N-1:0] reg_wr_data; 
wire [N-1:0] reg_rd_data0, reg_rd_data1;
output wire [32*32-1:0] full_register_file;

register_file #(.N(N)) REGISTER_FILE(
	.clk(clk), .rst(rst), .wr_ena(reg_wr_ena),
	.rd_addr0(reg_rd_addr0), .rd_addr1(reg_rd_addr1),
	.rd_data0(reg_rd_data0), .rd_data1(reg_rd_data1),
	.wr_addr(reg_wr_addr), .wr_data(reg_wr_data),
	.full_register_file(full_register_file)
	
);

//CUT<<<
//instruction decode
wire [31:0] sign_extended_immediate, sign_extended_shifted_immediate, jump_address;
wire [5:0] op_code, funct;
wire [4:0] shamt;
wire [4:0] rd, rt, rs;
wire [`MIPS_TYPE_WIDTH-1:0] instruction_type;

mips_decoder DECODER (
	.instruction(IR),
	.PC(PC),
	.sign_extended_immediate(sign_extended_immediate),
	.sign_extended_shifted_immediate(sign_extended_shifted_immediate),
	.op_code(op_code),
	.funct(funct),
	.shamt(shamt),
	.rd(rd),
	.rt(rt),
	.rs(rs),
	.jump_address(jump_address),
	.type(instruction_type)
);


always @(posedge clk) begin
	if(rst) begin
		IR <= 0;
		DR <= 0;
		exec_result <= 0;
		reg_A <= 0;
		reg_B <= 0;
		instruction_number <= 0;
	end
	else begin
		if (IR_ena) begin
			IR <= mem_rd_data;
		end
		alu_last_result <= alu_result;
		if(state == `S_EXECUTE) begin
			exec_result <= alu_result;
		end
		if(state == `S_DECODE) begin
			reg_A <= reg_rd_data0;
			reg_B <= reg_rd_data1;
		end
		if(state == `S_MEMORY2) begin //todo check that this works
			DR <= mem_rd_data;
		end
		if((state == `S_FETCH1) && ena) begin
			 instruction_number <= (PC[11:2]) + 1;
		end
	end
end

//control muxes
reg [`ALU_SRC_A_SW_WIDTH-1:0] alu_src_a_sw;
reg [`ALU_SRC_B_SW_WIDTH-1:0] alu_src_b_sw; 
reg [`PC_SRC_SW_WIDTH-1:0]    pc_src_sw; 
always @(*) begin
	//alu src a
	case (alu_src_a_sw)
		`ALU_SRC_A_SW_REG_A : alu_src_a = reg_A;
		`ALU_SRC_A_SW_PC    : alu_src_a = PC;
		default             : alu_src_a = 0;
	endcase
	//alu src b
	case (alu_src_b_sw)
		`ALU_SRC_B_SW_REG_B  : alu_src_b = reg_B;
		`ALU_SRC_B_SW_SEI    : alu_src_b = sign_extended_immediate;
		`ALU_SRC_B_SW_SESI   : alu_src_b = sign_extended_shifted_immediate;
		`ALU_SRC_B_SW_4      : alu_src_b = 32'd4;
		`ALU_SRC_B_SW_16     : alu_src_b = 32'd16;
		`ALU_SRC_B_SW_SHAMT  : alu_src_b = shamt;
		default              : alu_src_b = 0;
	endcase
	//next PC
	case (pc_src_sw)
		`PC_SRC_SW_ALU      : next_PC = alu_result;
		`PC_SRC_SW_ALU_LAST : next_PC = alu_last_result;
		
		`PC_SRC_SW_JUMP 	: next_PC = jump_address;
		default             : next_PC = 32'hFFFF_FFFF; //failure mode
	endcase
end


/* ----------------- moore FSM for different instruction types -----------------------*/
always @(posedge clk) begin
	if(rst) begin
		state <= `S_FETCH1;
		instruction_count <= 32'd0;
		PC <= {`I_START_ADDRESS, 20'h0};
	end
	else begin
		if (ena || (~ena && (next_state !== `S_FETCH1))) begin
			state <= next_state;
			if (state == `S_FETCH2) begin
				instruction_count <= instruction_count + 1;
			end
			if(PC_ena) begin
				last_PC <= PC;
				PC <= next_PC;
			end
		end
	end
end
//	combinational logic
always @(*) begin
	if(rst) begin
		PC_ena  = 0;
		IR_ena  = 0;
		dmem_wr_ena = 0;
		reg_wr_ena = 0;
		pc_src_sw = `PC_SRC_SW_ALU;
	end
	else begin
		PC_ena = 0;
		IR_ena = 0;
		dmem_wr_ena = 0;
		reg_wr_ena = 0;
		pc_src_sw = `PC_SRC_SW_ALU;
		alu_src_a_sw = 0;
		alu_src_b_sw = 0;
		alu_op = 0;
		next_state = `S_FAILURE;
		reg_rd_addr0 = 0;
		reg_rd_addr1 = 0;
		reg_wr_addr = 0;
		reg_wr_data = 0;
		dmem_rd_addr = 0;
		alu_op = 0;
		case (state)
			/* ---------------- FETCH ---------------- */
			`S_FETCH1: begin
				IR_ena  = 0;
				dmem_wr_ena = 0;
				reg_wr_ena = 0;
				//set PC to PC + 4 with this ena/mux src combo
				PC_ena  = 1;
				pc_src_sw = `PC_SRC_SW_ALU;
				alu_op = `ALU_OP_ADD;
				alu_src_a_sw = `ALU_SRC_A_SW_PC;
				alu_src_b_sw = `ALU_SRC_B_SW_4;

				next_state = `S_FETCH2;
			end
			`S_FETCH2: begin
				IR_ena  = 1;
				dmem_wr_ena = 0;
				reg_wr_ena = 0;
				//PC = PC + 4
				PC_ena  = 0;
				pc_src_sw = `PC_SRC_SW_ALU;
				alu_op = `ALU_OP_ADD;
				alu_src_a_sw = `ALU_SRC_A_SW_PC;
				alu_src_b_sw = `ALU_SRC_B_SW_4;

				next_state = `S_DECODE;
			end
			/* ---------------- DECODE ---------------- */
			`S_DECODE : begin
				PC_ena  = 0;
				IR_ena  = 0;
				dmem_wr_ena = 0;
				reg_wr_ena = 0;
				reg_rd_addr0 = rs;
				reg_rd_addr1 = rt;
				//compute branch target just in case
				alu_op = `ALU_OP_ADD;
				alu_src_a_sw = `ALU_SRC_A_SW_PC;
				alu_src_b_sw = `ALU_SRC_B_SW_SESI;
				next_state = `S_EXECUTE;
			end
			/* ---------------- EXECUTE ---------------- */
			`S_EXECUTE: begin
				`ifdef VERBOSE
				if(op_code === 6'b000000) begin					
					$display("@%10t::E:: line %3d, op = %8s (%b), funct = %8s (%b)", $time, instruction_number, op_code_string(op_code), op_code, funct_code_string(funct), funct);
				end
				else begin
					$display("@%10t::E:: line %3d, op = %8s (%b)", $time, instruction_number, op_code_string(op_code), op_code);
				end
				`endif
				PC_ena  = 0;
				IR_ena  = 0;
				dmem_wr_ena = 0;
				reg_wr_ena = 0;
				case(instruction_type)
					/* ---------------- EXEC R ---------------- */
					`MIPS_TYPE_R : begin
						PC_ena = 0;
						alu_src_a_sw = `ALU_SRC_A_SW_REG_A;
						if( (funct === `MIPS_FUNCT_SLL) || (funct === `MIPS_FUNCT_SRL) || (funct === `MIPS_FUNCT_SRA) ) begin
							alu_src_b_sw = `ALU_SRC_B_SW_SHAMT;
						end
						else begin
							alu_src_b_sw = `ALU_SRC_B_SW_REG_B;
						end
						
						reg_wr_ena = 0;
						case (funct)
							`MIPS_FUNCT_AND :	alu_op = `ALU_OP_AND;
							`MIPS_FUNCT_OR  :	alu_op = `ALU_OP_OR ;
							`MIPS_FUNCT_XOR :	alu_op = `ALU_OP_XOR;	
							`MIPS_FUNCT_NOR :	alu_op = `ALU_OP_NOR;
							`MIPS_FUNCT_ADD :	alu_op = `ALU_OP_ADD;
							`MIPS_FUNCT_ADDU:	alu_op = `ALU_OP_ADD;
							`MIPS_FUNCT_SUB :	alu_op = `ALU_OP_SUB;
							`MIPS_FUNCT_SUBU:	alu_op = `ALU_OP_SUB;
							`MIPS_FUNCT_SLL :	alu_op = `ALU_OP_SLL;
							`MIPS_FUNCT_SLLV:	alu_op = `ALU_OP_SLL;
							`MIPS_FUNCT_SRL :	alu_op = `ALU_OP_SRL;
							`MIPS_FUNCT_SRLV:	alu_op = `ALU_OP_SRL;
							`MIPS_FUNCT_SRA :	alu_op = `ALU_OP_SRA;
							`MIPS_FUNCT_SRAV:	alu_op = `ALU_OP_SRA;
							`MIPS_FUNCT_SLT :   alu_op = `ALU_OP_SLT;
							`MIPS_FUNCT_JR  :   alu_op = `ALU_OP_ADD;
							default         :	alu_op = `ALU_OP_ADD;
						endcase
						next_state = `S_WRITEBACK;
					end
					/* ---------------- EXEC I ---------------- */
					`MIPS_TYPE_I : begin
						PC_ena = 0;
						alu_src_a_sw = `ALU_SRC_A_SW_REG_A;
						alu_src_b_sw = `ALU_SRC_B_SW_SEI;
						reg_wr_ena = 0;
						case (op_code)
							`MIPS_OP_ADDI, `MIPS_OP_ADDIU : alu_op = `ALU_OP_ADD;
							`MIPS_OP_SLTI, `MIPS_OP_SLTIU : alu_op = `ALU_OP_SLT;
							`MIPS_OP_ANDI                 : alu_op = `ALU_OP_AND;
							`MIPS_OP_ORI                  : alu_op = `ALU_OP_OR;
							`MIPS_OP_XORI                 : alu_op = `ALU_OP_XOR;
							default                       : alu_op = `ALU_OP_ADD;
						endcase
						next_state = `S_WRITEBACK;
					end
					/* ---------------- EXEC M ---------------- */
					`MIPS_TYPE_M : begin
						PC_ena = 0;
						alu_op = `ALU_OP_ADD;
						alu_src_a_sw = `ALU_SRC_A_SW_REG_A;
						alu_src_b_sw = `ALU_SRC_B_SW_SEI;
						reg_wr_ena = 0;
						next_state = `S_MEMORY1;
					end
					/* ---------------- EXEC J ---------------- */
					`MIPS_TYPE_J : begin
						//you will need to update this code!
						reg_wr_ena = 0;
						next_state = `S_FAILURE;
						PC_ena = 0;
						pc_src_sw = 0;
						alu_src_a_sw = `ALU_SRC_A_SW_REG_A;
						alu_src_b_sw = `ALU_SRC_B_SW_REG_B;
					end
					/* ---------------- EXEC B ---------------- */
					`MIPS_TYPE_B : begin
						//you will need to update this code!
						reg_wr_ena = 0;
						next_state = `S_FAILURE;
						PC_ena = 0;
						pc_src_sw = 0;
						alu_src_a_sw = `ALU_SRC_A_SW_REG_A;
						alu_src_b_sw = `ALU_SRC_B_SW_REG_B;
					end
					default: begin
						PC_ena = 0;
						next_state = `S_FAILURE;
					end
				endcase
			end
			/* ---------------- MEMORY ---------------- */
			`S_MEMORY1: begin
				PC_ena  = 0;
				IR_ena  = 0;
				reg_wr_ena = 0;
				mem_wr_data = 0;
				case (op_code)
					`MIPS_OP_LW : begin
						dmem_rd_addr = alu_last_result;
						dmem_wr_ena = 0;
						next_state = `S_MEMORY2;
					end
					`MIPS_OP_SW : begin
						mem_wr_data = reg_B;
						dmem_wr_addr = alu_last_result;
						dmem_wr_ena = 1;
						next_state = `S_FETCH1;
					end
					default: begin
						IR_ena  = 0;
						next_state = `S_FAILURE;
					end
				endcase
			end
			`S_MEMORY2: begin
				PC_ena  = 0;
				IR_ena  = 0;
				reg_wr_ena = 0;
				case (op_code)
					`MIPS_OP_LW : begin
						dmem_rd_addr = alu_last_result;
						dmem_wr_ena = 0;
						next_state = `S_WRITEBACK;
						`ifdef VERBOSE
						$display("@%10t::M:: line %3d, op = %8s (%b),dmem_rd_addr = %h", $time, instruction_number, op_code_string(op_code), op_code, dmem_rd_addr);
						`endif
					end
					default: begin
						dmem_wr_ena = 0;
						next_state = `S_FAILURE;
					end
				endcase
			end
			/* ---------------- WRITEBACK ---------------- */
			`S_WRITEBACK: begin
				IR_ena  = 0;
				PC_ena = 0;
				dmem_wr_ena = 0;
				reg_wr_ena = 0;
				next_state = `S_FETCH1;
				case (instruction_type)
					`MIPS_TYPE_R: begin
						//you might need to do something special here for JR
						reg_wr_ena = 1;
						reg_wr_addr = rd;
						reg_wr_data = alu_last_result;
						pc_src_sw = `PC_SRC_SW_ALU;
						PC_ena = 0;					
					end
					`MIPS_TYPE_I: begin
						reg_wr_ena = 1;
						reg_wr_addr = rt;
						reg_wr_data = alu_last_result;
					end
					`MIPS_TYPE_M: begin
						case (op_code)
							`MIPS_OP_LW : begin
								`ifdef VERBOSE
								$display("@%10t::W:: line %3d, op = %8s (%b), DR = %h", $time, instruction_number, op_code_string(op_code), op_code, DR);
								`endif
								reg_wr_ena = 1;
								reg_wr_addr = rt;
								reg_wr_data = DR;
							end
							default: begin
							`ifdef VERBOSE
								$display("@%10t::W:: line %3d, op = %8s (%b), FAILURE1", $time, instruction_number, op_code_string(op_code), op_code);
								`endif
								$finish;
								reg_wr_ena = 0;
								next_state = `S_FAILURE;
							end
						endcase
					end //M-type
					`MIPS_TYPE_J: begin
						next_state = `S_FAILURE;
					end
					default: begin
					`ifdef VERBOSE
						$display("@%10t::W:: line %3d, op = %8s (%b), FAILURE2: i_type = %d", $time, instruction_number, op_code_string(op_code), op_code, instruction_type);
					`endif
						next_state = `S_FAILURE;
					end
				endcase
			end
			default: begin
				PC_ena = 0;
				dmem_wr_ena = 0;
				`ifdef VERBOSE
				$display("this fail6? state = %d", state);
				`endif
				next_state = `S_FAILURE;
			end
		endcase
	end
end


//>>>

endmodule

`default_nettype wire

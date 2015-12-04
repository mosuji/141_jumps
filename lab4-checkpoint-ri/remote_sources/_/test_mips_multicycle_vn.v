`include "mips_multicycle_defines.v"

`default_nettype none
`timescale 1ns/1ps

module test_mips_multicycle_vn;

//module cli args
integer NUM_CYCLES = 100;
integer DATA_MEM_START;
integer DATA_MEM_STOP;
integer i;
reg [8*100:0] WAVE_FILE;


//UUT parameters
parameter N = 32;

//UUT IO
reg  clk, rst, ena;
wire rstb;
assign rstb = ~rst;
//memory
wire [N-1:0] mem_wr_data, mem_addr;
wire [N-1:0] mem_rd_data;
wire mem_wr_ena;
wire mem_invalid;

synth_dual_port_memory #(
	.N(32),
	.I_LENGTH(1024),
	.D_LENGTH(1024)
) MEMORY(
	.clk(clk),
	.rstb(rstb),
	.wr_ena0(mem_wr_ena),
	.addr0(mem_addr),
	.din0(mem_wr_data),
	.dout0(mem_rd_data),
	.invalid0(mem_invalid)
);

//mips core
mips_multicycle_vn UUT (
	.clk(clk),
	.rst(rst),
	.ena(ena),
	.mem_addr(mem_addr),
	.mem_rd_data(mem_rd_data),
	.mem_wr_data(mem_wr_data),
	.mem_wr_ena(mem_wr_ena)
);

initial begin
	clk = 0;
	rst = 1;
	
	if(!$value$plusargs("NUM_CYCLES=%d", NUM_CYCLES)) begin
		$display("defaulting to 100 cycles");
		NUM_CYCLES = 100;
	end
	
	if(!$value$plusargs("WAVE_FILE=%s", WAVE_FILE)) begin
		WAVE_FILE = "waves/mips_multicycle_vn.vcd";
		$display("outputing to default wave file '%s'", WAVE_FILE);
		
	end
	
	$dumpfile(WAVE_FILE);
	$dumpvars(0, UUT);
	
	repeat (2) @(posedge clk); rst = 0;
	
	repeat (NUM_CYCLES) @(negedge clk); //run the CPU
	$display("simulated %d cycles", NUM_CYCLES);
	$display("register file final state dump:\n");
	UUT.REGISTER_FILE.print_decimal;
	
	if(!$value$plusargs("DATA_MEM_START=%d", DATA_MEM_START)) begin
		DATA_MEM_START = 0;
	end
	if(!$value$plusargs("DATA_MEM_STOP=%d", DATA_MEM_STOP)) begin
		DATA_MEM_STOP = 0;
	end
	
	if (DATA_MEM_STOP > DATA_MEM_START) begin
		$display("Dumping data memory from address %d -> %d:", DATA_MEM_START, DATA_MEM_STOP);
		
		for (i = DATA_MEM_START; i < DATA_MEM_STOP; i = i + 1) begin
			$display("\tDMEM[%d]=%h", i, MEMORY.DMEM[i]);
		end
	end
	
	$finish;
end

reg TEST_ENA = 0;
initial begin	
	ena = 1;
	if(!$value$plusargs("TEST_ENA=%b", TEST_ENA)) begin
		TEST_ENA = 0;
	end	
	while (TEST_ENA) begin
		@(negedge clk);
		ena = 0;
		repeat (100) @(negedge clk);
		ena = 1;
	end
end

always #5 clk = ~clk;

always @(posedge clk) begin
	if(UUT.state == `S_FAILURE) begin
		$display("%10t:: MIPS FSM FAILURE at instruction %d.  Quitting now.", $time, UUT.instruction_count);
		$finish;
	end	
end

endmodule

`default_nettype wire

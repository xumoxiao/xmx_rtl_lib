
// *************************************************************************************************
// Vendor 			: XmX
// Author 			: Moxiao Xu
// Filename 		: asyn_fifo
// Date Created 	: 2018.08.18
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:
//		创建异步fifo, 通过gray code进行地址编码
// -------------------------------------------------------------------------------------------------
// Revision History :
// *************************************************************************************************

`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------

module asyn_fifo
#(
	parameter WIDTH			= 32,
	parameter DEPTH 		= 512,
	parameter FWFT			= "FALSE",
	parameter ALM_FULL_VAL	= 256,
	parameter ALM_EMPTY_VAL	= 256,
	parameter PROTECT_WRITE	= "FALSE",
	parameter PROTECT_READ	= "FALSE",
	parameter SIM 			= "FALSE",
	parameter DEBUG			= "FALSE"
)
(
	//------------------------------------------------
	// Write Port Define
	//------------------------------------------------
	input							i_wr_clk,
	input							i_wr_rst,
	
	input 							i_wr_en,
	input 	[WIDTH - 1 : 0]			i_wr_data,
	output 							o_wr_full,
	output 							o_wr_almost_full,
	output 	[log2(DEPTH) - 1 : 0]	o_wr_data_cnt,
	//------------------------------------------------
	// Read Port Define
	//------------------------------------------------
	input 							i_rd_clk,
	input 							i_rd_rst,
	
	input 							i_rd_en,
	output 	[WIDTH - 1 : 0]			o_rd_data,
	output							o_rd_empty,
	output							o_rd_almost_empty,
	output 	[log2(DEPTH) - 1 : 0]	o_rd_data_cnt
);

	localparam DEPTH_WIDTH 	= log2(DEPTH); 		// 
	localparam ADDR_WIDTH 	= log2(DEPTH - 1); 	// 
	//------------------------------------------------
	// log2(x) function
	//------------------------------------------------
	function integer log2 (input integer depth);
	begin
		for(log2 = 0; depth>0; log2 = log2 + 1) depth = depth >> 1;
	end
	endfunction

	//----------------------------------------------------------------------------------------------
	// struct define
	//----------------------------------------------------------------------------------------------
	typedef struct {
		logic [ADDR_WIDTH - 1 	: 0] 	wr_addr;
		logic 							wr_flag;
		logic [DEPTH_WIDTH - 1 	: 0]	wr_data_cnt;
		logic [1:0]						syn_rd_flag;
		logic [ADDR_WIDTH - 1 	: 0] 	syn_rd_addr	[1:0];
		logic [WIDTH - 1 		: 0] 	buff 		[DEPTH - 1 : 0];
  	} asyn_fifo_wr_s;
	
	typedef struct {
		logic [ADDR_WIDTH - 1 	: 0] 	rd_addr;
		logic 							rd_flag;
		logic [DEPTH_WIDTH - 1 	: 0]	rd_data_cnt;
		logic [DEPTH_WIDTH - 1 	: 0]	rd_ft_data_cnt;
		logic [WIDTH - 1 		: 0]	rd_data;
		logic [1:0]						syn_wr_flag;
		logic [ADDR_WIDTH - 1 	: 0] 	syn_wr_addr	[1:0];
		logic							rd_ft_vld;
  	} asyn_fifo_rd_s;
	
	
	logic [ADDR_WIDTH - 1 : 0]	gray_wr_addr;
	logic [ADDR_WIDTH - 1 : 0] 	gray_rd_addr;
	
	//----------------------------------------------------------------------------------------------
	// Register define
	//----------------------------------------------------------------------------------------------
  	asyn_fifo_wr_s rw,rwn;
  	asyn_fifo_rd_s rr,rrn;
	
	logic rd_empty_ft;
	logic rd_en_i;// 内部读使能
	logic wr_en_i;// 内部写使能
	
	//----------------------------------------------------------------------------------------------
	// combinatorial always
	//----------------------------------------------------------------------------------------------
	always_comb begin	
		rwn = rw;
		rrn = rr;
		// ----- Write Part ----- 
		rwn.syn_rd_flag 	= {rw.syn_rd_flag[0], rr.rd_flag};
		rwn.syn_rd_addr[0]	= rr.rd_addr;
		rwn.syn_rd_addr[1]	= rw.syn_rd_addr[0];
		
		if(wr_en_i == 1'b1) begin
			rwn.wr_addr 			= rw.wr_addr + 1'b1;
			rwn.buff[gray_wr_addr]	= i_wr_data;
			if(rw.wr_addr == DEPTH - 1) begin
				rwn.wr_addr = {ADDR_WIDTH{1'b0}};
				rwn.wr_flag = ~rw.wr_flag;
			end
		end
		
		rwn.wr_data_cnt = rw.wr_addr - rw.syn_rd_addr[1];
		if(rw.wr_flag ^ rw.syn_rd_flag) begin
			rwn.wr_data_cnt = DEPTH - rw.syn_rd_addr[1] + rw.wr_addr;
		end
		
		// ----- Read Part ----- 
		rrn.syn_wr_flag 	= {rr.syn_wr_flag[0], rw.wr_flag};
		rrn.syn_wr_addr[0]	= rw.wr_addr;
		rrn.syn_wr_addr[1]	= rr.syn_wr_addr[0];
		
		if(i_rd_en == 1'b1) begin
			rrn.rd_addr = rr.rd_addr + 1'b1;
			if(rr.rd_addr == DEPTH - 1) begin
				rrn.rd_addr = {ADDR_WIDTH{1'b0}};
				rrn.rd_flag = ~rr.rd_flag;
			end
		end
		
		rrn.rd_data_cnt = rr.syn_wr_addr[1] - rr.rd_addr;
		if(rr.rd_flag ^ rr.syn_wr_flag) begin
			rrn.rd_data_cnt = DEPTH - rr.rd_addr + rr.syn_wr_addr[1];
		end
		
		if(FWFT == "FALSE") begin
			if(i_rd_en == 1'b1) begin
				rrn.rd_data = rw.buff[gray_rd_addr];
			end
		end else begin 
			rrn.rd_ft_data_cnt = rrn.rd_data_cnt + rr.rd_ft_vld;
			
			if(i_rd_en == 1'b1) begin
				rrn.rd_ft_vld 	= 1'b0;
			end
			// 需要在 内部添加一级pipeline
			if(rd_en_i)begin //内部读取
				rrn.rd_data 	= rw.buff[gray_rd_addr];
				rrn.rd_ft_vld 	= 1'b1;
			end
		end
		
	end
	
	//----------------------------------------------------------------------------------------------
	// internal assignment
	//----------------------------------------------------------------------------------------------
	assign rd_en_i 			= (!rr.rd_ft_vld ||(rr.rd_ft_vld & i_rd_en))&&(rr.rd_data_cnt != {DEPTH_WIDTH{1'b0}});
	assign wr_en_i 			= (PROTECT_WRITE == "TRUE")? (i_wr_en & o_wr_full) : i_wr_en;
	assign rd_empty_ft		= !rr.rd_ft_vld;
	
	//----------------------------------------------------------------------------------------------
	// Gray Code Gen
	//----------------------------------------------------------------------------------------------
	assign gray_wr_addr = rw.wr_addr ^ (rw.wr_addr >> 1);
	assign gray_rd_addr = rr.rd_addr ^ (rr.rd_addr >> 1);
	
	//----------------------------------------------------------------------------------------------
	// Output assignment
	//----------------------------------------------------------------------------------------------
	assign o_wr_full 			= (rw.wr_data_cnt >= DEPTH)? 1'b1 : 1'b0;
	assign o_wr_almost_full 	= (rw.wr_data_cnt >= ALM_FULL_VAL)? 1'b1 : 1'b0;
	assign o_wr_data_cnt		= rw.wr_data_cnt;
	assign o_rd_data			= rr.rd_data;
	
	generate
		if(FWFT == "FALSE") begin
			assign o_rd_empty			= (rr.rd_data_cnt == {DEPTH_WIDTH{1'b0}})? 1'b1 : 1'b0;
			assign o_rd_almost_empty	= (rr.rd_data_cnt <= ALM_EMPTY_VAL)? 1'b1 : 1'b0;
			assign o_rd_data_cnt		= rr.rd_data_cnt;		
		end else begin
			assign o_rd_empty			= rd_empty_ft;
			assign o_rd_almost_empty	= (rr.rd_ft_data_cnt <= ALM_EMPTY_VAL)? 1'b1 : 1'b0;
			assign o_rd_data_cnt		= rr.rd_ft_data_cnt;
		end
	endgenerate
	//----------------------------------------------------------------------------------------------
	// sequential always
	//----------------------------------------------------------------------------------------------	
	always_ff @(posedge i_wr_clk) begin
		rw <= rwn;
		if(i_wr_rst == 1) begin
			rw.wr_addr 			<= {ADDR_WIDTH{1'b0}};
			rw.wr_flag			<= 1'b0;
			rw.wr_data_cnt 		<= {DEPTH_WIDTH{1'b0}};
			rw.syn_rd_flag		<= 2'd0;
			rw.syn_rd_addr[0]	<= {ADDR_WIDTH{1'b0}};
			rw.syn_rd_addr[1]	<= {ADDR_WIDTH{1'b0}};
		end
	end
	
	always_ff @(posedge i_rd_clk) begin
		rr <= rrn;
		if(i_rd_rst == 1) begin
			rr.rd_addr			<= {ADDR_WIDTH{1'b0}};
			rr.rd_flag			<= 1'b0;
			rr.rd_data_cnt		<= {DEPTH_WIDTH{1'b0}};
			rr.rd_ft_data_cnt	<= {DEPTH_WIDTH{1'b0}};
			rr.rd_data			<= {WIDTH{1'b0}};
			rr.syn_wr_flag		<= 2'd0;
			rr.syn_wr_addr[0]	<= {ADDR_WIDTH{1'b0}};
			rr.syn_wr_addr[1]	<= {ADDR_WIDTH{1'b0}};
			rr.rd_ft_vld		<= 1'b0;
		end
	end

endmodule

//--------------------------------------------------------------------------------------------------
// eof
//--------------------------------------------------------------------------------------------------


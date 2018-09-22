
// *************************************************************************************************
// Vendor 			: XmX
// Author 			: Moxiao Xu
// Filename 		: asyn_fifo_tb
// Date Created 	: 2018.08.18
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:
// -------------------------------------------------------------------------------------------------
// Revision History :
// *************************************************************************************************

`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------

module asyn_fifo_tb
#(
	parameter WIDTH			= 32,
	parameter DEPTH 		= 512,
	parameter FWFT			= "FALSE",
	parameter ALM_FULL_VAL	= 256,
	parameter ALM_EMPTY_VAL	= 256,
	parameter PROTECT_WRITE	= "FALSE",
	parameter PROTECT_READ	= "FALSE",
	parameter SIM 			= "FALSE",
	parameter DEBUG			= "FALSE",
	parameter CLK_WR_FREQ	= 100000000,
	parameter CLK_RD_FREQ	= 200000000
)
();

	//----------------------------------------------------------------------------------------------
	// param define
	//----------------------------------------------------------------------------------------------
	localparam 		CLK_WR_FREQ_M	= CLK_WR_FREQ/1000000;
	localparam		WrRespAcqTime 	= ((1e3/CLK_WR_FREQ_M)/10)*8;
	
	localparam 		CLK_RD_FREQ_M	= CLK_RD_FREQ/1000000;
	localparam		RdRespAcqTime 	= ((1e3/CLK_RD_FREQ_M)/10)*8;

	localparam 		DEPTH_WIDTH 	= log2(DEPTH); 		// 
	localparam 		ADDR_WIDTH 		= log2(DEPTH - 1); 	// 
	//------------------------------------------------
	// log2(x) function
	//------------------------------------------------
	function integer log2 (input integer depth);
	begin
		for(log2 = 0; depth>0; log2 = log2 + 1) depth = depth >> 1;
	end
	endfunction

	//------------------------------------------------
	// Write Port Define
	//------------------------------------------------
	logic 							wr_clk;
	logic 							wr_rst;
	logic 							wr_en;
	logic 	[WIDTH - 1 : 0]			wr_data;
	logic  							wr_full;
	logic  							wr_almost_full;
	logic  	[log2(DEPTH) - 1 : 0]	wr_data_cnt;
	//------------------------------------------------
	// Read Port Define
	//------------------------------------------------
	logic							rd_clk;
	logic							rd_rst;
	logic							rd_en;
	logic 	[WIDTH - 1 : 0]			rd_data;
	logic							rd_empty;
	logic							rd_almost_empty;
	logic 	[log2(DEPTH) - 1 : 0]	rd_data_cnt;
	
	logic 							wr_en_i;
	logic 							rd_en_i;
	logic 							rd_en_r;
	//------------------------------------------------
	// Clk Define
	//------------------------------------------------
	initial begin
		wr_clk = 0;
		forever #((1e3/CLK_WR_FREQ_M)/2) wr_clk = !wr_clk;
	end
	
	initial begin
		rd_clk = 0;
		forever #((1e3/CLK_RD_FREQ_M)/2) rd_clk = !rd_clk;
	end
	
	//------------------------------------------------
	// init input
	//------------------------------------------------
	initial begin
		wr_rst 	= 1'b1;
		wr_en_i = 1'b0;
		wr_data	= {WIDTH{1'b0}};
		rd_rst	= 1'b1;
		rd_en_i	= 1'b0;
		#1000;
		@(posedge wr_clk);
		wr_rst 	= 1'b0;
		@(posedge rd_clk);
		rd_rst	= 1'b0;
	end
	
	initial begin
		@(negedge wr_rst);
		@(negedge rd_rst);
		#1000;
		case0();
		case1();
		#5000;
		$finish;
	end
	
	//------------------------------------------------
	// task: case0
	//------------------------------------------------
	task case0();
	begin
		$display("----- case0 Write or Read start -----");
		wr_t(512);
		#1000;
		rd_t(512);
		$display("----- case0 finish -----");
	end 
	endtask
	
	//------------------------------------------------
	// task: case1
	//------------------------------------------------
	task case1();
	begin
		$display("----- case1 Write and Read start -----");
		fork
		wr_t(512);
		rd_t(512);
		join
		$display("----- case0 finish -----");
	end 
	endtask
	
	
	//------------------------------------------------
	// task: wr_t
	//------------------------------------------------
	task wr_t(
		input integer len
	);
	automatic integer wr_cnt;
	begin
		wr_cnt 	= 0;
		wr_en_i = 1'b0;
		while(wr_cnt < len)begin
			@(posedge wr_clk) begin
				wr_en_i <= 1'b1;
				wr_data	<= wr_cnt;
			end
			#WrRespAcqTime;
			while(wr_en == 1'b0) begin
				@(posedge wr_clk);
				#WrRespAcqTime;
			end
			wr_cnt = wr_cnt + 1'b1;
		end
		@(posedge wr_clk) begin
			wr_en_i <= 1'b0;
		end
	end
	endtask
	
	
	//------------------------------------------------
	// task: rd_t
	//------------------------------------------------
	task rd_t(
		input integer len
	);
	automatic integer rd_cnt;
	automatic integer rd_data_cnt;
	begin	
		rd_cnt 		= 0;
		rd_en_i 	= 1'b0;
		rd_data_cnt	= 0;
		fork 
		begin
			while(rd_cnt < len)begin
				@(posedge rd_clk) begin
					rd_en_i <= 1'b1;
				end
				#RdRespAcqTime;
				while(rd_en == 1'b0) begin
					@(posedge rd_clk);
					#RdRespAcqTime;
				end
				rd_cnt = rd_cnt + 1'b1;
			end
			@(posedge rd_clk) begin
				rd_en_i <= 1'b0;
			end
		end
		begin
			while(rd_data_cnt < len)begin
				@(posedge rd_clk)
				#RdRespAcqTime;
				while(rd_en_r == 1'b0) begin
					@(posedge rd_clk);
					#RdRespAcqTime;
				end
				if(rd_data_cnt != rd_data)begin
					$display("***Err***: Wrong Data Rd Exp = %d, Rcv = %d, At: %d", rd_data_cnt, rd_data, $time);
					#100;$stop;
				end
				rd_data_cnt = rd_data_cnt + 1'b1;
			end
		end
		join	
	end
	endtask
	
	always@(posedge rd_clk)begin
		rd_en_r <= rd_en;
	end
	
	assign wr_en = wr_en_i & !wr_full;
	assign rd_en = rd_en_i & !rd_empty;
	//------------------------------------------------------------------------------------------------
	// Module Name : asyn_fifo                                                                        
	// Description :                                                                                  
	//------------------------------------------------------------------------------------------------
	asyn_fifo
	#(
		.WIDTH            	( WIDTH            	),
		.DEPTH            	( DEPTH            	),
		.FWFT             	( FWFT             	),
		.ALM_FULL_VAL     	( ALM_FULL_VAL     	),
		.ALM_EMPTY_VAL    	( ALM_EMPTY_VAL    	),
		.PROTECT_WRITE    	( PROTECT_WRITE    	),
		.PROTECT_READ     	( PROTECT_READ     	),
		.SIM              	( SIM              	),
		.DEBUG            	( DEBUG            	) 
	)
	u_asyn_fifo
	(
		.i_wr_clk         	( wr_clk         	),//input 
		.i_wr_rst         	( wr_rst         	),//input 
		.i_wr_en          	( wr_en          	),//input 
		.i_wr_data        	( wr_data        	),//input WIDTH - 1 : 0
		.o_wr_full        	( wr_full        	),//output 
		.o_wr_almost_full 	( wr_almost_full 	),//output 
		.o_wr_data_cnt    	( wr_data_cnt    	),//output log2(DEPTH) - 1 : 0
		.i_rd_clk         	( rd_clk         	),//input 
		.i_rd_rst         	( rd_rst         	),//input 
		.i_rd_en          	( rd_en          	),//input 
		.o_rd_data        	( rd_data        	),//output WIDTH - 1 : 0
		.o_rd_empty       	( rd_empty       	),//output 
		.o_rd_almost_empty	( rd_almost_empty	),//output 
		.o_rd_data_cnt    	( rd_data_cnt    	) //output log2(DEPTH) - 1 : 0
	);


endmodule

//--------------------------------------------------------------------------------------------------
// eof
//--------------------------------------------------------------------------------------------------


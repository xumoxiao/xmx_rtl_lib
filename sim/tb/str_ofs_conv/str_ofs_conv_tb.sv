
// *************************************************************************************************
// Vendor           : Wuhan JingCe Electronic Technology Co., Ltd
// Author           : Moxiao Xu
// Filename         : str_ofs_conv_tb
// Date Created     : 2018.09.15
// Version          : V1.0
// -------------------------------------------------------------------------------------------------
// File description :
// -------------------------------------------------------------------------------------------------
// Revision History :
// *************************************************************************************************


`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------

module str_ofs_conv_tb
#(
	parameter RANDOM_HANDSHAKE	= "TRUE",
	parameter DATA_WIDTH 		= 32,
	parameter BYTE_WIDTH 		= 8,
	parameter SIM 				= "FALSE",
	parameter DEBUG 			= "FALSE"
)();

    //----------------------------------------------------------------------------------------------
    // Localparam define
    //----------------------------------------------------------------------------------------------
	localparam CLK_FREQ_M = 100;
	localparam CLK_RESP_TIME_NS = ((1e3/CLK_FREQ_M)/10)*8;
	
	//------------------------------------------------
	// log2(x) function
	//------------------------------------------------
	function integer log2 (input integer depth);
		for(log2 = 0; depth>0; log2 = log2 + 1) depth = depth >> 1;
	endfunction
	
    //----------------------------------------------------------------------------------------------
    // Logic define
    //----------------------------------------------------------------------------------------------
	logic 												clk;
	logic 												rst;
	logic 												conv_vld;
	logic 												conv_rdy;
	logic [log2(DATA_WIDTH/BYTE_WIDTH - 1) - 1 : 0]		conv_s_ofs;
	logic [log2(DATA_WIDTH/BYTE_WIDTH - 1) - 1 : 0]		conv_m_ofs;
	logic [31:0]										conv_b_len;
	logic [DATA_WIDTH - 1 : 0]							s_axis_tdata;
	logic [DATA_WIDTH/BYTE_WIDTH - 1 : 0]				s_axis_tkeep;
	logic 												s_axis_tlast;
	logic 												s_axis_tvld;
	logic 												s_axis_trdy;
	logic [DATA_WIDTH - 1 : 0]							m_axis_tdata;
	logic [DATA_WIDTH/BYTE_WIDTH - 1 : 0]				m_axis_tkeep;
	logic 												m_axis_tlast;
	logic 												m_axis_tvld;
	logic 												m_axis_trdy;
	logic 												s_axis_tvld_i;
	logic 												m_axis_trdy_i;
	logic 												s_axis_tvld_rd;
	logic 												m_axis_trdy_rd;
	logic [63:0] xmx = 64'd4634495716965153813;
	integer byte_len;
	integer tx_cnt;
	integer rx_cnt;
	integer i;
	genvar 	j;
	
	logic [7:0] tx_data [DATA_WIDTH/8 - 1 : 0];
	logic [7:0] rx_data [DATA_WIDTH/8 - 1 : 0];
	
	
	generate
		for(j = 0; j < DATA_WIDTH/8; j = j + 1) begin
			assign s_axis_tdata[8*(j + 1) - 1 : 8*j] = tx_data[j]; // 发送	
		end
		for(j = 0; j < DATA_WIDTH/8; j = j + 1) begin
			assign rx_data[j] = m_axis_tdata[8*(j + 1) - 1 : 8*j];	// 接收
		end
	endgenerate
    //----------------------------------------------------------------------------------------------
    // Logic Init
    //----------------------------------------------------------------------------------------------
    initial begin
		conv_vld = 0;
		conv_s_ofs = 0;
		conv_m_ofs = 0;
		//s_axis_tdata = 0;
		conv_b_len = 0;
		s_axis_tkeep = 0;
		s_axis_tlast = 0;
		s_axis_tvld_i = 0;
		m_axis_trdy_i = 0;
    end

    //----------------------------------------------------------------------------------------------
    // Clock define
    //----------------------------------------------------------------------------------------------

    initial begin
        clk = 0;
        forever #((1e3/CLK_FREQ_M)/2) clk = !clk;
    end

    //----------------------------------------------------------------------------------------------
    // TestCase
    //----------------------------------------------------------------------------------------------
    initial begin
		rst = 1;
		#1000;
		@(posedge clk);
		rst = 0;
        #1000;
        //----- TestCase Start -----
		case0(0,0,10);
		case0(0,3,10);
		case0(3,0,10);
		case0(2,2,10);
		case0(3,2,10);
		case0(2,3,10);
		
		case0(0,0,2);
		case0(0,3,2);
		case0(3,0,2);
		case0(2,2,2);
		case0(3,2,2);
		case0(2,3,2);
		
		case0(0,0,200);
		case0(0,3,200);
		case0(3,0,200);
		case0(2,2,200);
		case0(3,2,200);
		case0(2,3,200);
        //----- Testcase Finish -----
        #1000;
        $finish;
    end

	//----------------------------------------------------------------------------------------------
	// task define
	//----------------------------------------------------------------------------------------------
		
	task case0(
		input [log2(DATA_WIDTH/BYTE_WIDTH - 1) - 1 : 0]	s_ofs,
		input [log2(DATA_WIDTH/BYTE_WIDTH - 1) - 1 : 0] m_ofs,
		input [31:0] 									len // byte 长度
	);
	automatic integer tx_b_cnt = 0;
	automatic integer rx_b_cnt = 0;
	begin
		byte_len = len;
		tx_cnt = 0;
		rx_cnt = 0;

		fork : c0_f
		begin
			@(posedge clk) begin
				conv_vld 	<= 1'b1;
				conv_s_ofs	<= s_ofs;
				conv_m_ofs	<= m_ofs;
				conv_b_len	<= byte_len;
			end
			#CLK_RESP_TIME_NS;
			while(conv_rdy == 1'b0 || conv_vld == 1'b0)begin
				@(posedge clk);
				#CLK_RESP_TIME_NS;
			end
			@(posedge clk) begin
				conv_vld 	<= 1'b0;
			end
		end
		begin
			//--- send data ---
			while(tx_cnt < byte_len) begin
				@(posedge clk) begin
					s_axis_tvld_i 	<= 1'b1;
					s_axis_tkeep 	= 0;
					for(i = 0; (i < DATA_WIDTH/8) && (tx_cnt < byte_len); i = i + 1) begin
						tx_data		[i] <= tx_cnt;
						s_axis_tkeep[i] <= 1'b0;
						if(tx_b_cnt >= s_ofs) begin
							tx_cnt 			= tx_cnt + 1;
							s_axis_tkeep[i] <= 1'b1;
						end
						tx_b_cnt		= tx_b_cnt + 1;
					end
					s_axis_tlast <= 1'b1;
					if(tx_cnt<byte_len)s_axis_tlast <= 1'b0;
				end
				#CLK_RESP_TIME_NS;
				while(s_axis_trdy == 1'b0 || s_axis_tvld == 1'b0)begin
					@(posedge clk);
					#CLK_RESP_TIME_NS;
				end
			end
			@(posedge clk) begin
				s_axis_tvld_i 	<= 1'b0;
				s_axis_tlast 	<= 1'b0;
			end
		end
		begin		
			//--- check data ---
			while (rx_cnt < byte_len) begin
				@(posedge clk) begin
					m_axis_trdy_i <= 1'b1;
				end
				#CLK_RESP_TIME_NS;
				while(m_axis_tvld == 1'b0 || m_axis_trdy == 1'b0)begin
					@(posedge clk);
					#CLK_RESP_TIME_NS;
				end
				for(i = 0; i < DATA_WIDTH/8 && (rx_cnt < byte_len); i = i + 1) begin
					rx_b_cnt = rx_b_cnt + 1;
					if(rx_b_cnt > m_ofs) begin
						if(rx_cnt < byte_len) begin
							if(rx_data[i] == 8'dx) begin
								$display("***Err***: Wrong Data Rcv. Exp = %d, Rcv = x At: %t.", rx_cnt[7:0], $time);
								#100;
								$stop;
							end
							if(rx_data[i] != rx_cnt[7:0] ) begin
								$display("***Err***: Wrong Data Rcv. Exp = %d, Rcv = %d At: %t.", rx_cnt[7:0], rx_data[i], $time);
								#100;
								$stop;
							end
							if(m_axis_tkeep[i] != 1'b1) begin
								$display("***Err***: Wrong Keep Rcv. Exp = 1, Rcv = 0 At: %t.", $time);
								#100;
								$stop;
							end
						end
						else begin
							if(m_axis_tkeep[i] != 1'b0) begin
								$display("***Err***: Wrong Keep Rcv. Exp = 0, Rcv = 1, i = %d At: %t.", i, $time);
								#100;
								$stop;
							end
						end
						rx_cnt = rx_cnt + 1;
					end else begin
						if(m_axis_tkeep[i] != 1'b0) begin
							$display("***Err***: Wrong Keep Rcv. Exp = 0, Rcv = 1, i = %d At: %t.", i, $time);
							#100;
							$stop;
						end
					end
					
				end
            
				if(rx_cnt < byte_len) begin
					if(m_axis_tlast != 0)begin
						$display("***Err***: Wrong Last Rcv. Exp = 0, Rcv = 1 At: %t.", $time);
						#100;
						$stop;
					end
				end else begin
					if(m_axis_tlast != 1)begin
						$display("***Err***: Wrong Last Rcv. Exp = 1, Rcv = 0 At: %t.", $time);
						#100;
						$stop;
					end
				end
			end
			@(posedge clk) begin
				m_axis_trdy_i <= 1'b0;
			end
		end
		join
	end 
	endtask
	
	
	//----------------------------------------------------------------------------------------------
    // Task Define
    //----------------------------------------------------------------------------------------------
	initial begin
		s_axis_tvld_rd = 0;
		forever begin
			repeat({$random}%20) @(posedge clk);
			s_axis_tvld_rd = ~s_axis_tvld_rd;
		end
	end
	
	initial begin
		m_axis_trdy_rd = 0;
		forever begin
			repeat({$random}%20) @(posedge clk);
			m_axis_trdy_rd = ~m_axis_trdy_rd;
		end
	end


	assign s_axis_tvld = (RANDOM_HANDSHAKE == "TRUE") ? s_axis_tvld_i & s_axis_tvld_rd : s_axis_tvld_i;
	assign m_axis_trdy = (RANDOM_HANDSHAKE == "TRUE") ? m_axis_trdy_i & m_axis_trdy_rd : m_axis_trdy_i;
	//----------------------------------------------------------------------------------------------
	// Module Name : str_ofs_conv
	// Description :                                                                                  
	//----------------------------------------------------------------------------------------------
	str_ofs_conv
	#(
		.DATA_WIDTH  	(	DATA_WIDTH  	),
		.BYTE_WIDTH  	(	BYTE_WIDTH  	),
		.BLK_B_NUM		( 	1				),
		.MODE			(	0 				),
		.SIM         	(	SIM         	),
		.DEBUG       	(	DEBUG       	) 
	)
	u_str_ofs_conv
	(
		.i_clk       	(	clk         	),//input  &&Clk
		.i_rst       	(	rst         	),//input  &&Rst
		.i_conv_vld  	(	conv_vld    	),//input 
		.o_conv_rdy  	(	conv_rdy    	),//output 
		//.i_conv_b_len	( 	conv_b_len		),
		.i_conv_s_ofs	(	conv_s_ofs  	),//input log2(DATA_WIDTH/BYTE_WIDTH - 1) - 1 : 0
		.i_conv_m_ofs	(	conv_m_ofs  	),//input log2(DATA_WIDTH/BYTE_WIDTH - 1) - 1 : 0
		.s_axis_tdata	(	s_axis_tdata	),//input DATA_WIDTH - 1 : 0
		.s_axis_tkeep	(	s_axis_tkeep	),//input DATA_WIDTH/BYTE_WIDTH - 1 : 0
		.s_axis_tlast	(	s_axis_tlast	),//input 
		.s_axis_tvld 	(	s_axis_tvld 	),//input 
		.s_axis_trdy 	(	s_axis_trdy 	),//output 
		.m_axis_tdata	(	m_axis_tdata	),//output DATA_WIDTH - 1 : 0
		.m_axis_tkeep	(	m_axis_tkeep	),//output DATA_WIDTH/BYTE_WIDTH - 1 : 0
		.m_axis_tlast	(	m_axis_tlast	),//output 
		.m_axis_tvld 	(	m_axis_tvld 	),//output 
		.m_axis_trdy 	(	m_axis_trdy 	) //input 
	);


endmodule
//--------------------------------------------------------------------------------------------------
// Eof
//--------------------------------------------------------------------------------------------------


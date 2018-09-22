
// *************************************************************************************************
// Vendor 			: Wuhan JingCe Electronic Technology Co., Ltd
// Author 			: Moxiao Xu
// Filename 		: str_width_conv_tb
// Date Created 	: 2018.07.05
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

module str_width_conv_tb
#(
	parameter RANDOM_HANDSHAKE	= "TRUE", // 随机握手，开启后握手信号随机生成。
	parameter I_WIDTH 			= 10*8,
	parameter O_WIDTH 			= 8*8,
	parameter CLK_FREQ			= 200000000
)
(
);
	//----------------------------------------------------------------------------------------------
	// param define
	//----------------------------------------------------------------------------------------------
	localparam 		CLK_FREQ_M	= CLK_FREQ/1000000;
	localparam		RespAcqTime = ((1e3/CLK_FREQ_M)/10)*8;

	//----------------------------------------------------------------------------------------------
	// logic define
	//----------------------------------------------------------------------------------------------	
	logic						i_clk;
	logic						i_rst;
	logic	[I_WIDTH - 1   : 0]	s_axis_tdata;
	logic	[I_WIDTH/8 - 1 : 0] s_axis_tkeep;
	logic						s_axis_tlast;
	logic						s_axis_tvld;
	logic						s_axis_trdy;
	logic	[O_WIDTH - 1   : 0] m_axis_tdata;
	logic  	[O_WIDTH/8 - 1 : 0] m_axis_tkeep;
	logic  						m_axis_tlast;
	logic  						m_axis_tvld;
	logic  						m_axis_trdy;
	logic 						s_axis_tvld_i;
	logic 						m_axis_trdy_i;
	logic 						s_axis_tvld_rd;
	logic 						m_axis_trdy_rd;
	integer byte_len;
	integer tx_cnt;
	integer rx_cnt;
	integer i;
	genvar 	j;
	
	logic [7:0] tx_data [I_WIDTH/8 - 1 : 0];
	logic [7:0] rx_data [O_WIDTH/8 - 1 : 0];
	
	
	generate
		for(j = 0; j < I_WIDTH/8; j = j + 1) begin
			assign s_axis_tdata[8*(j + 1) - 1 : 8*j] = tx_data[j]; // 发送	
		end
		for(j = 0; j < O_WIDTH/8; j = j + 1) begin
			assign rx_data[j] = m_axis_tdata[8*(j + 1) - 1 : 8*j];	// 接收
		end
	endgenerate
	//----------------------------------------------------------------------------------------------
	// clk define
	//----------------------------------------------------------------------------------------------
	initial begin
		i_clk = 0;
		forever #((1e3/CLK_FREQ_M)/2) i_clk = !i_clk;
	end
	
	initial begin
		i_rst 			= 1'b1;
		//s_axis_tdata 	= 0;
		s_axis_tkeep 	= 0;
		s_axis_tlast	= 0;
		s_axis_tvld_i  	= 0;
		m_axis_trdy_i	= 0;
		#1000;
		@(posedge i_clk);
		i_rst 			= 1'b0;
	end
	
	initial begin
		@(negedge i_rst);
		#100;
		$display("--- case0 Width Convert test Start! ---");
		repeat(10) begin
			case0(100);
			case0(1000);
			case0(1880);
			case0(4880);
			case0(8840);
		end
		$display("--- case0 Finish! ---");
		#1000;
		$finish;
	end
	
	//----------------------------------------------------------------------------------------------
	// task define
	//----------------------------------------------------------------------------------------------
		
	task case0(
		input [31:0] len // byte 长度
	);
	begin
		byte_len = len * (I_WIDTH/8);
		tx_cnt = 0;
		rx_cnt = 0;
		if(byte_len % (I_WIDTH/8) != 0) begin $display("***Err***: Wrong Byte Len", $time); #100; $stop; end
		
		fork : c0_f
		begin
			//--- send data ---
			while(tx_cnt < byte_len) begin
				@(posedge i_clk) begin
					s_axis_tvld_i 	<= 1'b1;
					s_axis_tkeep 	= 0;
					for(i = 0; (i < I_WIDTH/8) && (tx_cnt < byte_len); i = i + 1) begin
						tx_data		[i] <= tx_cnt;
						s_axis_tkeep[i] <= 1'b1;
						tx_cnt 			= tx_cnt + 1;
					end
					s_axis_tlast <= 1'b1;
					if(tx_cnt<byte_len)s_axis_tlast <= 1'b0;
				end
				#RespAcqTime;
				while(s_axis_trdy == 1'b0 || s_axis_tvld == 1'b0)begin
					@(posedge i_clk);
					#RespAcqTime;
				end
			end
			@(posedge i_clk) begin
				s_axis_tvld_i 	<= 1'b0;
				s_axis_tlast 	<= 1'b0;
			end
		end
		begin
		
			//--- check data ---
			while (rx_cnt < byte_len) begin
				@(posedge i_clk) begin
					m_axis_trdy_i <= 1'b1;
				end
				#RespAcqTime;
				while(m_axis_tvld == 1'b0 || m_axis_trdy == 1'b0)begin
					@(posedge i_clk);
					#RespAcqTime;
				end
				for(i = 0; i < O_WIDTH/8 && (rx_cnt < byte_len); i = i + 1) begin
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
							$display("***Err***: Wrong Keep Rcv. Exp = 0, Rcv = 1 At: %t.", $time);
							#100;
							$stop;
						end
					end
					rx_cnt = rx_cnt + 1;
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
			@(posedge i_clk) begin
				m_axis_trdy_i <= 1'b0;
			end
		end
		join
	end 
	endtask
	
	initial begin
		s_axis_tvld_rd = 0;
		forever begin
			repeat({$random}%20) @(posedge i_clk);
			s_axis_tvld_rd = ~s_axis_tvld_rd;
		end
	end
	
	initial begin
		m_axis_trdy_rd = 0;
		forever begin
			repeat({$random}%20) @(posedge i_clk);
			m_axis_trdy_rd = ~m_axis_trdy_rd;
		end
	end

	
	assign s_axis_tvld = (RANDOM_HANDSHAKE == "TRUE") ? s_axis_tvld_i & s_axis_tvld_rd : s_axis_tvld_i;
	assign m_axis_trdy = (RANDOM_HANDSHAKE == "TRUE") ? m_axis_trdy_i & m_axis_trdy_rd : m_axis_trdy_i;
		
	//------------------------------------------------------------------------------------------------
	// Module Name : str_width_conv                                                                   
	// Description :                                                                                  
	//------------------------------------------------------------------------------------------------
	str_width_conv
	#(
		.I_WIDTH      	( I_WIDTH      	),
		.O_WIDTH      	( O_WIDTH      	) 
	)
	u_str_width_conv
	(
		.i_clk        	( i_clk        	),//input 
		.i_rst        	( i_rst        	),//input 
		.s_axis_tdata  	( s_axis_tdata  ),//input I_WIDTH - 1   : 0
		.s_axis_tkeep 	( s_axis_tkeep 	),//input I_WIDTH/8 - 1 : 0
		.s_axis_tlast 	( s_axis_tlast 	),//input 
		.s_axis_tvld  	( s_axis_tvld  	),//input 
		.s_axis_trdy  	( s_axis_trdy  	),//output 
		.m_axis_tdata 	( m_axis_tdata 	),//output O_WIDTH - 1   : 0
		.m_axis_tkeep	( m_axis_tkeep	),//output I_WIDTH/8 - 1 : 0
		.m_axis_tlast	( m_axis_tlast	),//output 
		.m_axis_tvld 	( m_axis_tvld 	),//output 
		.m_axis_trdy 	( m_axis_trdy 	) //input 
	);

endmodule

//--------------------------------------------------------------------------------------------------
// eof
//--------------------------------------------------------------------------------------------------


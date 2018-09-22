
// *************************************************************************************************
// Vendor 			: XmX
// Author 			: Moxiao Xu
// Filename 		: str_width_conv
// Date Created 	: 2018.07.13
// Version 			: V1.0
// -------------------------------------------------------------------------------------------------
// File description	:
//	添加两级pipeline: Buff, M_AXIS
// 	-----------------------
// 	S_AXIS | Buff | M_AXIS
// 	-----------------------
//  首先将buff设置为输入输出的最小公倍数，参考 双口fifo的设计思路，输入计数地址（inp_ofs）,输出计数
//  地址oup_ofs,差值大于 M_AXIS位宽 Buff输出到 m_axis
// -------------------------------------------------------------------------------------------------
// Revision History :
// *************************************************************************************************

`timescale   1ns/1ps
//--------------------------------------------------------------------------------------------------
// module declaration
//--------------------------------------------------------------------------------------------------

module str_width_conv
#(
	parameter I_WIDTH 		= 10*8,
	parameter O_WIDTH 		= 8*8,
	parameter WORD_WIDTH	= 8
)
(
	//------------------------------------------------
	// Port define
	//------------------------------------------------
	input								i_clk,
	input								i_rst,
	
	input 	[I_WIDTH - 1 : 0]			s_axis_tdata,
	input 	[I_WIDTH/WORD_WIDTH - 1: 0]	s_axis_tkeep,
	input								s_axis_tlast,
	input								s_axis_tvld,
	output 								s_axis_trdy,
	
	output 	[O_WIDTH - 1 : 0]			m_axis_tdata,
	output 	[O_WIDTH/WORD_WIDTH - 1: 0]	m_axis_tkeep,
	output								m_axis_tlast,
	output								m_axis_tvld,
	input 								m_axis_trdy

);
	//------------------------------------------------
	// log2(x) function
	//------------------------------------------------
	function integer log2 (input integer depth);
	begin
		for(log2 = 0; depth>0; log2 = log2 + 1) depth = depth >> 1;
	end
	endfunction
	
	//------------------------------------------------
	// Greatest common divisor - gcd function
	//------------------------------------------------
	function integer gcd (input integer k,input integer y);
		automatic integer t,r = 1,rr = 1;
	begin
		if(k>y) begin t = y;y =k;k = t; end
		while(r != 0)begin
			rr = r; r = y - k;
			if(r > k)begin y = r; end
			else begin y = k; k = r; end
		end		
		gcd = rr;
	end
	endfunction
	//------------------------------------------------
	// Lowest common multiple - lcm function
	//------------------------------------------------
	function integer lcm (input integer k,input integer y);
	begin
		lcm = (k*y/gcd(k,y));
	end
	endfunction
	
	
	localparam LCM			= lcm(O_WIDTH,I_WIDTH); 	
	localparam RAM_DEPTH 	= LCM/WORD_WIDTH;
	localparam RD_WIDTH	 	= log2(RAM_DEPTH);
	localparam I_CNT_WIDTH	= log2(I_WIDTH);
	localparam O_CNT_WIDTH	= log2(O_WIDTH);
	localparam I_DEPTH		= LCM/I_WIDTH;
	localparam O_DEPTH		= LCM/O_WIDTH;
	localparam I_UINT		= I_WIDTH/WORD_WIDTH;
	localparam O_UINT		= O_WIDTH/WORD_WIDTH;

	// 带宽，提前rdy		
	localparam PRE_WIDTH	= log2(I_UINT + O_UINT);
	
	
	//----------------------------------------------------------------------------------------------
	// struct define
	//----------------------------------------------------------------------------------------------
	typedef struct {
		logic 								rcv_last;
		logic [I_WIDTH - 1 : 0] 			buff 		[I_DEPTH - 1 : 0];
		
		logic 								buff_last;
		logic [I_CNT_WIDTH - 1 : 0]			inp_cnt;
		logic [RD_WIDTH - 1 : 0]			inp_ofs;
		logic 								inp_flag;
		
		logic [O_CNT_WIDTH - 1 : 0]			oup_cnt;
		logic [RD_WIDTH - 1 : 0]			oup_ofs;
		logic 								oup_flag;
		
		logic [O_WIDTH - 1 : 0]				tx_data;
		logic [O_UINT - 1 : 0] 				tx_keep;
		logic 								tx_vld;
		logic 								tx_last;
		logic [RD_WIDTH - 1 : 0]			buff_cnt;
		
		// 只在 I_WIDTH > O_WIDTH 时使用
		logic [PRE_WIDTH - 1 : 0]			oup_pre_cnt;
  	} str_width_conv_s;

	//----------------------------------------------------------------------------------------------
	// Register define
	//----------------------------------------------------------------------------------------------
  	str_width_conv_s r,rn;
	
	logic [LCM - 1 : 0] 				tt_reg;
	logic [O_WIDTH - 1 : 0] 			oup_buff 		[O_DEPTH - 1 : 0];
	logic pre_rdy;
	logic buff_vld,buff_rdy,buff_last;
	integer i, k;
	genvar j;
	
	//----------------------------------------------------------------------------------------------
	// combinatorial always
	//----------------------------------------------------------------------------------------------

	always_comb begin	
		rn = r;
		
		if(s_axis_tvld & s_axis_trdy) begin
			rn.inp_ofs = r.inp_ofs + I_UINT;
			if(r.inp_ofs + I_UINT >= RAM_DEPTH)begin
				rn.inp_ofs 	= r.inp_ofs + I_UINT - RAM_DEPTH;
				rn.inp_flag	= !r.inp_flag;
			end
			
			// 计数 输入 数组 编号
			rn.inp_cnt = r.inp_cnt + 1'b1;
			if(r.inp_cnt == I_DEPTH - 1)begin
				rn.inp_cnt = {I_CNT_WIDTH{1'b0}};
			end
			
			rn.buff[r.inp_cnt] 		= s_axis_tdata;
			rn.rcv_last 			= s_axis_tlast; // 收到 last 后停止接收数据。 等待发送完毕
		end
		
		if(m_axis_tvld & m_axis_trdy)begin
			rn.tx_vld 	= 1'b0;
			rn.tx_last 	= 1'b0;
		end
		
		
		if(buff_vld & buff_rdy) begin
			rn.oup_ofs 	= r.oup_ofs + O_UINT;
			if(r.oup_ofs + O_UINT >= RAM_DEPTH)begin
				rn.oup_ofs 	= r.oup_ofs + O_UINT - RAM_DEPTH;
				rn.oup_flag	= !r.oup_flag;
			end
			
			// 计数 输出 数组 编号
			rn.oup_cnt = r.oup_cnt + 1'b1;
			if(r.oup_cnt == O_DEPTH - 1)begin
				rn.oup_cnt = {O_CNT_WIDTH{1'b0}};
			end
			
			rn.tx_data 	= oup_buff[r.oup_cnt];

			rn.tx_vld  = 1'b1;
			rn.tx_keep = {O_UINT{1'b1}};
			if(buff_last == 1'b1) begin
				for(i = 0; i < O_UINT; i = i + 1) begin
					if(i >= r.buff_cnt) begin
						rn.tx_keep[i] = 1'b0;
					end
				end
				rn.tx_last = 1'b1;
				rn.rcv_last= 1'b0;
			end

			if(O_WIDTH < I_WIDTH) begin
				rn.oup_pre_cnt = r.oup_ofs + O_UINT;
				if(r.oup_pre_cnt + O_UINT >= I_UINT) begin
					rn.oup_pre_cnt = r.oup_pre_cnt + O_UINT - I_UINT;
				end
			end
		end
		
		if(buff_vld & buff_rdy & buff_last) begin
			rn.inp_cnt		= {I_CNT_WIDTH{1'b0}};
			rn.inp_ofs 		= {RD_WIDTH{1'b0}};
			rn.inp_flag		= 1'b0;
			rn.oup_cnt		= {O_CNT_WIDTH{1'b0}};
			rn.oup_ofs 		= {RD_WIDTH{1'b0}};
			rn.oup_flag		= 1'b0;
			rn.oup_pre_cnt  = {PRE_WIDTH{1'b0}};
		end
		
		rn.buff_cnt = rn.inp_ofs - rn.oup_ofs;
		if(rn.inp_flag ^ rn.oup_flag) begin // 不同时
			rn.buff_cnt = RAM_DEPTH - rn.oup_ofs + rn.inp_ofs;
		end
	
	end

	//----------------------------------------------------------------------------------------------
	// internal assignment
	//----------------------------------------------------------------------------------------------
	assign pre_rdy  = (O_WIDTH >= I_WIDTH && (buff_vld & buff_rdy))? 1'b1:
					  (O_WIDTH < I_WIDTH && (buff_vld & buff_rdy) &&(r.oup_pre_cnt + O_UINT >= I_UINT))? 1'b1: 1'b0;
	
	assign buff_vld = (r.buff_cnt >= O_UINT || buff_last ) ? 1'b1: 1'b0;
	assign buff_rdy = (m_axis_trdy | !m_axis_tvld);
	assign buff_last= (r.buff_cnt <= O_UINT && r.rcv_last) ? 1'b1: 1'b0;
	
	generate
		for(j = 0; j < I_DEPTH; j = j + 1) begin
			assign tt_reg[(j+1)*I_WIDTH - 1 : j*I_WIDTH] = r.buff[j];
		end
		for(j = 0; j < O_DEPTH; j = j + 1) begin
			assign oup_buff[j]	= tt_reg[(j+1)*O_WIDTH - 1 : j*O_WIDTH];
		end
	endgenerate
	
	//----------------------------------------------------------------------------------------------
	// output assignment
	//----------------------------------------------------------------------------------------------
	assign s_axis_trdy 	= (r.rcv_last == 1'b0)? (((RAM_DEPTH - r.buff_cnt) >= I_UINT) || pre_rdy == 1'b1) : 1'b0;
	assign m_axis_tdata = r.tx_data;
	assign m_axis_tkeep = r.tx_keep;
	assign m_axis_tlast = r.tx_last;
	assign m_axis_tvld	= r.tx_vld;

	//----------------------------------------------------------------------------------------------
	// sequential always
	//----------------------------------------------------------------------------------------------	
	always_ff @(posedge i_clk) begin
		r <= rn;
		if(i_rst == 1) begin
			r.buff_last	<= 1'b0;
			r.inp_cnt	<= {I_CNT_WIDTH{1'b0}};
			r.inp_ofs	<= {RD_WIDTH{1'b0}};
			r.inp_flag	<= 1'b0;
			r.oup_cnt	<= {O_CNT_WIDTH{1'b0}};
			r.oup_ofs	<= {RD_WIDTH{1'b0}};
			r.oup_flag	<= 1'b0;
			r.rcv_last	<= 1'b0;
			r.tx_keep	<= {O_UINT{1'b0}};
			r.tx_vld	<= 1'b0;
			r.tx_last	<= 1'b0;
			r.buff_cnt	<= {RD_WIDTH{1'b0}};
			r.tx_data	<= {O_WIDTH{1'b0}};
			for(k = 0; k < I_DEPTH; k = k + 1) begin
				r.buff[k]	<= {I_WIDTH{1'b0}};
			end	
			r.oup_pre_cnt <= {PRE_WIDTH{1'b0}};
		end
	end

endmodule

//--------------------------------------------------------------------------------------------------
// eof
//--------------------------------------------------------------------------------------------------


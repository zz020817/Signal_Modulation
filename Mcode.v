/* 
这段代码的作用是根据本原多项式F(x) = x^15 + x^14 + 1生成一个序列信号，
并将序列信号的最高位输出到m_out信号中。
在时钟上升沿时，移位寄存器向左移动一位，并根据本原多项式更新最低位。
*/
 module Mcode(clk,rst_n,m,load);

	input  clk,rst_n;
	output  m,load;
	reg    m_out;

	reg  load;
	reg  [14:0] shift; //15级移位寄存器产生周期为2^15-1的序列

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin // 初始化
			m_out <= 1'b0;
			load <= 1'b0;
			shift <= 15'b0111_0111_0111_011;
		end
		else begin // 开始产生序列信号
			if (clk) begin
				shift <= {shift[13:0], shift[0]};	//将一位寄存器shift像左移一位
				shift[0] <= shift[13] ^ shift[14];  //计算并更新移位寄存器的最低位，对应本原多项式F(x) = x^15 + x^14 + 1
				load <= 1'b1;
			end
			else begin
				load <= 1'b0;
			end
			m_out <= shift[14];
		end
	end
	
	assign m = m_out;  //移位寄存
endmodule

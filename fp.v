module fp(clk,rst_n,clk256);
	input  rst_n,clk;
	output clk256;
	reg [8-1:0] q;

	always@(posedge clk or negedge  rst_n) begin
		if(rst_n == 0)
			q <= 8'b0000_0000_0000;
		else begin
			if( q == 8'b1111_1111 ) 
				q <= 8'b0000_0000;
			else
				q <= q + 1;
		end
	end

	assign clk256= q[7];
 
endmodule
  
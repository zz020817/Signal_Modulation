module Signal_Modulation(
	clk,
	rst_n,
	key,
	//DA端口(输出)
	dac_mode,
	dac_sleep, 
	dac_clka,
	dac_clkb,
	dac_da1,
	dac_da2,
	dac_wra,
	dac_wrb	
);

	input clk,rst_n;
	input [2:0] key;
	output dac_mode,dac_sleep;
	output dac_clka,dac_clkb;
	output dac_wra,dac_wrb;
	output [8-1:0] dac_da1;//输出调制信号
	output [8-1:0] dac_da2;//输出原始信号
	
	wire [8-1:0] address_a;
	wire [8-1:0] address_b;
	wire load;
	wire m;
	
/**********************频率控制字****************/
	reg [8-1:0] address1 = 8'd0;
	reg [8-1:0] address2 = 8'd0;
	reg [8-1:0] reg1;
	reg [8-1:0] reg2;
	//address1信号,控制调制信号的频率控制字
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			address1 <= 8'd0;
			reg1 <= 0;
			reg2 <= 127;
		end
		else if(address1 == 8'd255)
			address1 <= 8'd0;
		else begin
			case(key)
				3'b110: begin//ASK调制，正常波形/0
					if(m == 1)
						address1 <= address1 + 2'b01;
					else 
						address1 <= 8'd0;
				end
				3'b101:begin//FSK调制，两种波形的糅合
					if(m == 1)
						address1 <= address1 + 2'b10;
					else 
						address1 <= address1 + 2'b01;
				end
				3'b011:begin//PSK调制，相位
					if(m == 1) begin
						reg1 <= reg1 + 2'b01;
						address1 <= reg1;				 
					end
					else begin
						reg2 <= reg2 + 2'b01;
						address1 <= reg2;
					end
				end
				default: begin
					address1 <= address1 + 2'b01;
				end
			endcase
		end
	end	
	
	//address2信号,控制原始信号的频率控制字
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			address2 <= 8'd0;
		end
		else if(address2 == 8'd255)
			address2 <= 8'd0;
		else begin
			address2 <= address2 + 1'b1;
		end	
	end
	
	assign address_a = address1;
	assign address_b = address2;

/******************分频***********************/
	fp u1(
		.clk(clk),
		.rst_n(rst_n),
		.clk256(fpp)
	);	
/*****m序列产生，该模块用于生成一组伪随机序列*****/
	Mcode u2(
		.clk(fpp),
		.rst_n(rst_n),
		.m(m),				
		.load(load)//load是用于判断时钟信号和复位信号是否为高电平，如果是则load=1
	 );	
/*************调用双端口ROM**************/
	ROM u3(
		.address_a(address_a),
		.address_b(address_b),
		.clock(clk),
		.q_a(dac_da1),
		.q_b(dac_da2)
	);
	
/****************DA部分*****************/
	assign dac_clka = ~clk;
	assign dac_clkb = ~clk;
	assign dac_wra = dac_clka;
	assign dac_wrb = dac_clkb;
	assign dac_mode = 1;
	assign dac_sleep = 0;	
	
endmodule

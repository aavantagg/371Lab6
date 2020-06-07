module LFSR (clk, rst, out);

	input logic clk, rst;
	output logic [9:0] out;
	
	always_ff @(posedge clk)
	begin
		if(rst)
			out <= 10'b0000000000;
		else
			begin
			out[0] <= ~(out[9] ^ out[6]);
			out[1] <= out[0];
			out[2] <= out[1];
			out[3] <= out[2];
			out[4] <= out[3];
			out[5] <= out[4];
			out[6] <= out[5];
			out[7] <= out[6];
			out[8] <= out[7];
			out[9] <= out[8];
			end
	end
	
endmodule

module LFSR_testbench();
	
	logic clk, rst;
	logic [9:0] out;
	
	parameter CLOCK_PERIOD=100; // 100 ps period
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
		
	LFSR dut (.*);
	
	initial begin
		rst <= 1;			@(posedge clk);
								@(posedge clk);
		rst <= 0;			@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
			$stop;
	end
endmodule
		
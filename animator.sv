// Defines start and end points for line_drawer animation
// Lines stretch the width/height of the screen and rotate 360 degrees clockwise
module animator(clk, reset, x0, x1, y0, y1);

	input logic clk, reset;
	output logic [10:0] x0, x1, y0, y1;
		
	logic [10:0] counter;	
	
	always_ff @(posedge clk) begin
		if (reset) begin
			counter <= 0;
			x0 <= 0;
			x1 <= 639;
			y0 <= 0;
			y1 <= 479;
		end // if (reset)
		else begin
			// determine endpoints from counter
			if (counter == 0) begin
				x0 <= 0;
				x1 <= 639;
				y0 <= 0;
				y1 <= 479;
			end // if (counter == 0)
			else if (counter < 640) begin
				x0 <= x0 + 1'b1;
				x1 <= x1 - 1'b1;
				y0 <= 0;
				y1 <= 479;
			end // if (counter < 640)
			else if (counter < 1119) begin
				x0 <= 639;
				x1 <= 0;
				y0 <= y0 + 1'b1;
				y1 <= y1 - 1'b1;
			end // if (counter < 1120)
			
			// update counter
			if (counter == 1119)
				counter <= 0;
			else
				counter <= counter + 1;
		end // else
	end // always_ff	
endmodule // animator

// simulation test module for animator
module animator_testbench();

	logic clk, reset;
	logic [10:0] x0, x1, y0, y1;
	
	// set up clock
	initial begin
		clk <= 0;
		forever #(50) clk <= ~clk;
	end // initial

	animator dut (.*);
	
	initial begin
		reset = 1; @(posedge clk);
		reset = 0; @(posedge clk);
		for (int i = 0; i < 2240; i++) 
			@(posedge clk);
		
		$stop;
	end // initial
	
endmodule // animator_testbench
module pipe_drawer_top(clk, reset, enable, done, pipe_x, pipe_y, x, y);
	
	input logic clk, reset, enable;
	input logic [10:0] pipe_x, pipe_y;
	
	output logic done;
	output logic [10:0] x, y;

	enum {idle, line1, line2, line3, line4, line5, line6, line7} ps, ns;
	
	// helper variables
	logic [10:0] pipe_left, pipe_right, pipe_bottom, bevel;
	logic [10:0] counter; 	// arbritrary size for now
	
	always_comb begin
		case (ps)
			idle: if (enable & ((pipe_left - 1 > pipe_right) | (pipe_right <= 10))) ns = line4; // only draw part of pipe if off edge
					else if (enable) 				  ns = line1;
					else				  				  ns = idle;
					
			line1: if (y == pipe_bottom - bevel - 1)  ns = line2;
					 else											ns = line1;
					 
			line2: if (x == pipe_left - bevel + 1) 							ns = line3;
					 else if ((pipe_left - bevel > pipe_right) & x == 1)	ns = line4;
					 else								      							ns = line2;
					 
			line3: if (y == pipe_bottom - 1) ns = line4;
					 else							   ns = line3;
					 
			line4: if (x == pipe_right - 1 | x == pipe_right) 	ns = line5;
					 else								ns = line4;
					
			line5: if (y == pipe_bottom - bevel + 1) ns = line6;
					 else					    				  ns = line5;
					
			line6: if ((x == pipe_left + 1) | ((pipe_left > (pipe_right - bevel)) & x == 1)) ns = line7;
					 else if (pipe_right <= 10 & (x == 1 | x == 0))  									ns = idle;
					 else						    	  												ns = line6;
					 
			line7: if (y == 1) ns = idle;
					 else		    ns = line7;
					 
		endcase // ps
	end // always_comb
	
	always_ff @(posedge clk) begin
		if (reset)
			ps <= idle;
		else
			ps <= ns;
	end // always_ff
	
	// update coordinates based on state
	always_ff @(posedge clk) begin
		if (ps == idle) begin
			x <= 0;
			y <= 0;
		end // idle
		else if (ps == line1) begin
			x <= pipe_left;
			y <= counter;
		end // line1
		else if (ps == line2) begin
			x <= pipe_left - counter;
			y <= pipe_bottom - bevel;
		end // line2
		else if (ps == line3) begin
			x <= pipe_left - bevel;
			y <= pipe_bottom - bevel + counter;
		end // line3
		else if (ps == line4) begin
			if ((pipe_left - bevel) > pipe_right | pipe_left > pipe_right) begin
				x <= counter;
				y <= pipe_bottom;
			end else begin
				x <= pipe_left - bevel + counter;
				y <= pipe_bottom;
			end
		end // line4
		else if (ps == line5) begin
			x <= pipe_right;
			y <= pipe_bottom - counter;
		end // line5
		else if (ps == line6) begin
			x <= pipe_right - counter;
			y <= pipe_bottom - bevel;
		end // line6
		else if (ps == line7) begin
			x <= pipe_right - bevel;
			y <= pipe_bottom - bevel - counter;
		end // line7
	end // always_ff
	
	// update counter (resets for each new line)
	always_ff @(posedge clk) begin
		if ((ps == idle) | (ps != ns)) 	
			counter <= 0;
		else
			counter <= counter + 1;
	end //always_ff
	
	assign done = (ps == line7 | ps == line6) & (ns == idle);
	assign pipe_left = pipe_x - 60 - bevel;
	assign pipe_right = pipe_x;
	assign pipe_bottom = pipe_y - 80;
	assign bevel = 10;

endmodule // pipe_drawer

module pipe_drawer_top_testbench();

	logic clk, reset, enable;
	logic [10:0] pipe_x, pipe_y;
	
	logic done;
	logic [10:0] x, y;
	
	initial begin
		clk <= 0;
		forever #(50) clk <= ~clk;
	end // initial
	
	pipe_drawer dut (.*);
	
	initial begin
		reset = 1; enable = 0; pipe_x = 50; pipe_y = 380; @(posedge clk);
		reset = 0; @(posedge clk);
		
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		
		enable = 1; @(posedge clk);
		@(posedge done);
		enable = 0; @(posedge clk);
		
		pipe_x = 9; enable = 1; @(posedge clk);
		@(posedge done);
		enable = 0; @(posedge clk);
		
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		
		$stop;
	end // initial
endmodule // pipe_drawer_top_testbench
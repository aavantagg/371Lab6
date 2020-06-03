module bird_drawer(clk, reset, start, bird_x, bird_y, done, x, y);
	input logic clk, reset, start;
	input logic [10:0] bird_x, bird_y;
	
	output logic done;
	output logic [10:0] x, y;
	
	logic [3:0] template [0:99]; 
	logic [3:0] dir;
	logic [6:0] counter;
	
	initial begin
		$readmemb("C:/Users/casey/OneDrive/Documents/Spring 20/EE 371/Lab6/371Lab6/bird_template_v3.txt", template);
	end
	
	enum {s_idle, s_drawing, s_done} ps, ns;
	
	always_comb begin
		case (ps)
			s_idle: if (start) ns = s_drawing;
					  else 		 ns = s_idle;
					  
			s_drawing: if (counter == 73) ns = s_done;
						  else				   ns = s_drawing;
						  
			s_done: if (start) ns = s_done;
					  else		 ns = s_idle;		  
		endcase
	end // always_comb
	
	// update states
	always_ff @(posedge clk) begin
		if (reset)
			ps <= s_idle;
		else
			ps <= ns;	
	end // always_ff
	
	// update counter
	always_ff @(posedge clk) begin
		if (reset | (ps == s_idle))
			counter <= 0;
		else
			counter <= counter + 1;	
	end
	
	// update x and y based on directions given by glide_template
	always_ff @(posedge clk) begin
		if (ps == s_idle) begin
			x <= bird_x - 15;
			y <= bird_y;
		end // start coordinates
		else if (ps == s_drawing) begin
//			if (counter == 72) begin // unused rn
//				x <= bird_x - 13;
//				y <= bird_y + 2;
//			end
//			else 
			if (counter == 72) begin
				x <= bird_x - 4;
				y <= bird_y - 4;				
			end
			else if (counter == 73) begin
				x <= bird_x - 4;
				y <= bird_y - 3;
			end
			else begin
				if (dir[3:2] == 2'b10) 
					x <= x + 1;
				else if (dir[3:2] == 2'b01)
					x <= x - 1;
				if (dir[1:0] == 2'b10)
					y <= y + 1;
				else if (dir[1:0] == 2'b01)
					y <= y - 1;
			end // else
		end
	end // always_ff
	
	assign done = ps == s_done;
	assign dir = template[counter];

endmodule // bird_drawer

module bird_drawer_testbench();
	logic clk, reset, start;
	logic [10:0] bird_x, bird_y;
	
	logic done;
	logic [10:0] x, y;
	
	initial begin
		clk <= 0;
		forever #(50) clk <= ~clk;
	end
	
	bird_drawer dut (.*);
	
	initial begin
		reset = 1; start = 0; bird_x = 100; bird_y = 100; @(posedge clk);
		reset = 0; @(posedge clk);
		@(posedge clk);
		
		start = 1; @(posedge clk);
		@(posedge done);
		start = 0; @(posedge clk);
		@(posedge clk);
		@(posedge clk);
		$stop;
	end

endmodule // bird_drawer_testbench
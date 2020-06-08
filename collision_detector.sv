module collision_detector(clk, reset, bird_x, bird_y, pipe1_x, pipe1_y, pipe2_x, pipe2_y, restart, collision);
	
	input logic clk, reset, restart;
	input logic [10:0] bird_x, bird_y, pipe1_x, pipe1_y, pipe2_x, pipe2_y;
	
	output logic collision;
	
	enum {clear, dead} ps, ns;
	logic [10:0] pipe1_left, pipe1_right, pipe2_left, pipe2_right;
	logic hit_wall, hit_p1, hit_p2, hit_cap1, hit_cap2;
	logic [6:0] gap_size;
	
	always_comb begin
		case (ps)
			clear: if (hit_wall | hit_p1 | hit_p2 | hit_cap1 | hit_cap2) ns = dead;
					 else																	 ns = clear;
					 
			dead: if (restart) ns = clear;
					else			 ns = dead;
					
		endcase	
	end // always_comb
	
	always_ff @(posedge clk) begin
		if (reset)
			ps <= clear;
		else
			ps <= ns;	
	end
	
	assign hit_wall = (bird_y > 474) | (bird_y < 11);
	
	assign hit_p1 = (bird_x >= pipe1_left) & (bird_x <= pipe1_right) &
						 ((bird_y >= pipe1_y - 5) | (bird_y <= pipe1_y - gap_size + 7));
						 
	assign hit_p2 = (bird_x >= pipe2_left) & (bird_x <= pipe2_right) &
						 ((bird_y >= pipe2_y - 5) | (bird_y <= pipe2_y - gap_size + 7));
						 
	assign hit_cap1 = (bird_x >= pipe1_left - 10) & (bird_x <= pipe1_right) &
							((bird_y >= pipe1_y - 10 - 5) & (bird_y <= pipe1_y + 7) |
							(bird_y <= pipe1_y - gap_size + 7) & (bird_y >= pipe1_y - gap_size - 10 + 5));
	
	assign hit_cap2 = (bird_x >= pipe2_left - 10) & (bird_x <= pipe2_right) &
							((bird_y >= pipe2_y - 10 - 5) & (bird_y <= pipe2_y + 7) |
							(bird_y <= pipe2_y - gap_size + 7) & (bird_y >= pipe2_y - gap_size - 10 + 5));
							
	assign pipe1_left = pipe1_x - 60 - 10; // pipe x - width of pipe - right bevel
	assign pipe1_right = pipe1_x;
	assign pipe2_left = pipe2_x - 60 - 10;
	assign pipe2_right = pipe2_x;
	
	assign collision = ps == dead;
	assign gap_size = 80;

endmodule // collision_detector

module collision_detector_testbench();
	
	logic clk, reset, restart;
	logic [10:0] bird_x, bird_y, pipe1_x, pipe1_y, pipe2_x, pipe2_y;
	logic collision;
	
	initial begin
		clk <= 0;
		forever #(50) clk <= ~clk;
	end
	
	collision_detector dut (.*);
	
	initial begin
		reset = 1; bird_x = 100; bird_y = 50; pipe1_x = 200; pipe1_y = 100; @(posedge clk);
		reset = 0; @(posedge clk);
		@(posedge clk);
		for (int i = 0; i < 50; i++) begin
			bird_x = bird_x + 1;
			@(posedge clk);
		end
		@(posedge clk);
		@(posedge clk);
		restart = 1; bird_x = 100; @(posedge clk);
		restart = 0; @(posedge clk);
		$stop;
	end // initial
endmodule // collision
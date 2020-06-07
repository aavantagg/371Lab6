module display_manager(clk, reset, pipe1_x, pipe1_y, pipe2_x, pipe2_y, bird_x, bird_y, color, x, y,
							  clear_en, clear_done);

	input logic clk, reset, clear_en;
	input logic [10:0] pipe1_x, pipe1_y, pipe2_x, pipe2_y, bird_x, bird_y;
	
	output logic color;
	output logic [10:0] x, y;
	output logic clear_done;

	logic pipe1_done, pipe2_done, bird_done, bird_color;
	logic [10:0] p1x, p1y, p2x, p2y, bx, by, clrx, clry, p1t_x, p1t_y, p2t_x, p2t_y;
	logic p1t_done, p2t_done;
	
	enum {pipe1, pipe1_top, pipe2, pipe2_top, bird, clear} ps, ns; 
	
	// cycle between drawing each game object, clear screen when clear_en true
	always_comb begin
		case (ps)
			pipe1: if (pipe1_done) ns = pipe1_top;
					 else				  ns = pipe1;
					 
			pipe1_top: if (p1t_done) ns = pipe2;
						  else 			 ns = pipe1_top;
					 
			pipe2: if (pipe2_done) ns = pipe2_top; 
					 else				  ns = pipe2;
					 
			pipe2_top: if (p2t_done) ns = bird;
						  else			 ns = pipe2_top;
					 
			bird:  if (bird_done & clear_en)  ns = clear;
					 else if (bird_done)			 ns = pipe1;
					 else				  			  	 ns = bird;
					
			clear: if (clear_done) ns = pipe1;
					 else				  ns = clear;
					 
		endcase // ps
	end // always_comb
	
	clear_screen clr (.clk, 
							.enable		(ps == clear), 
							.done			(clear_done), 
							.x				(clrx), 
							.y				(clry));
	
	pipe_drawer pipe1_coords (.clk, 
									  .reset, 
									  .enable		(ps == pipe1), 	
									  .done			(pipe1_done), 
									  .pipe_x		(pipe1_x), 
									  .pipe_y		(pipe1_y), 
									  .x				(p1x), 
									  .y				(p1y));
									  
	pipe_drawer pipe2_coords (.clk, 
									  .reset, 
									  .enable		(ps == pipe2), 	
									  .done			(pipe2_done), 
									  .pipe_x		(pipe2_x), 
									  .pipe_y		(pipe2_y), 
									  .x				(p2x), 
									  .y				(p2y));
									  
	pipe_drawer_top p1_top (.clk, 
									.reset, 
									.enable			(ps == pipe1_top), 
									.done				(p1t_done), 
									.pipe_x			(pipe1_x), 
									.pipe_y			(pipe1_y), 
									.x					(p1t_x), 
									.y					(p1t_y));	
						
	pipe_drawer_top p2_top (.clk, 
									.reset, 
									.enable			(ps == pipe2_top), 
									.done				(p2t_done), 
									.pipe_x			(pipe2_x), 
									.pipe_y			(pipe2_y), 
									.x					(p2t_x), 
									.y					(p2t_y));				
	
	bird_drawer bird_coords (.clk, 
									 .reset, 
									 .start			(ps == bird), 
									 .bird_x, 
									 .bird_y, 
									 .done			(bird_done), 
									 .x				(bx), 
									 .y				(by));
	
	// set x and y to coordinates of current object
	always_comb begin
		if (ps == pipe1) begin
			x = p1x;
			y = p1y;
		end
		else if (ps == pipe1_top) begin
			x = p1t_x;
			y = p1t_y;
		end 
		else if (ps == pipe2_top) begin
			x = p2t_x;
			y = p2t_y;
		end
		else if (ps == pipe2) begin
			x = p2x;
			y = p2y;
		end
		else if (ps == bird) begin
			x = bx;
			y = by;
		end
		else begin
			x = clrx;
			y = clry;
		end
	end // always_comb
	
	always_ff @(posedge clk) begin
		if (reset)
			ps <= clear;
		else
			ps <= ns; 
	end // always_ff
	
	assign color = ps != clear;
	
endmodule // Display_Manager

module display_manager_testbench();

	logic clk, reset;
	logic [10:0] pipe1_x, pipe1_y, pipe2_x, pipe2_y, bird_x, bird_y;
	logic clear_en, clear_done;
	logic color;
	logic [10:0] x, y;
	
	initial begin
		clk <= 0;
		forever #(50) clk <= ~clk;
	end // initial
	
	display_manager dut (.*);
	
	initial begin
		reset = 1; pipe1_x = 100; pipe1_y = 380; pipe2_x = 200; 
		pipe2_y = 200; bird_x = 100; bird_y = 100; @(posedge clk);
		reset = 0; @(posedge clk);
		
		// clear for a whole lot of cycles, then draw a couple pipes
		for (int i = 0; i < 1000000; i++) begin
			@(posedge clk);
		end
	
		$stop;
	end // initial
endmodule // Display_Manager_testbench
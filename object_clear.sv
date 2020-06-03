module object_clear(clk, reset, enable, done, pipe1_x, pipe1_y, pipe2_x, pipe2_y, bird_x, bird_y, x, y);

	input logic clk, reset, enable;
	input logic [10:0] pipe1_x, pipe1_y, pipe2_x, pipe2_y, bird_x, bird_y;
	
	output logic done;
	output logic [10:0] x, y;
	
	enum {idle, pipe1, pipe2, bird} ps, ns;
	
	logic pipe1_done, pipe2_done, bird_done;
	logic p1x, p1y, p2x, p2y, bx, by;
	
	logic [10:0] p1x_prev, p1y_prev, p2x_prev, p2y_prev, bx_prev, by_prev;
	
	always_comb begin
		case (ps)
			idle: if (enable) ns = pipe1;
					else			ns = idle;
			
			pipe1: if (pipe1_done) ns = pipe2;
					 else				  ns = pipe1;
					 
			pipe2: if (pipe2_done) ns = bird; 
					 else				  ns = pipe2;
					 
			bird:  if (bird_done)  ns = idle;
					 else				  ns = bird;
					 
		endcase // ps
	end // always_comb
	
	pipe_drawer pipe1_clear (.clk, 
									  .reset, 
									  .enable		(ps == pipe1), 	
									  .done			(pipe1_done), 
									  .pipe_x		(p1x_prev), 
									  .pipe_y		(p1y_prev), 
									  .x				(p1x), 
									  .y				(p1y));
									  
	pipe_drawer pipe2_clear (.clk, 
									  .reset, 
									  .enable		(ps == pipe2), 	
									  .done			(pipe2_done), 
									  .pipe_x		(p2x_prev), 
									  .pipe_y		(p2y_prev), 
									  .x				(p2x), 
									  .y				(p2y));
									  
	bird_drawer bird_clear (.clk, 
									 .reset, 
									 .start			(ps == bird), 
									 .bird_x			(bx_prev), 
									 .bird_y			(by_prev), 
									 .done			(bird_done), 
									 .x				(bx), 
									 .y				(by));
	
	// set x and y to coordinates of current object
	always_comb begin
		if (ps == pipe1) begin
			if (p1x > 0 & p1x < 639)
				x = p1x;
			else
				x = 0;
				
			y = p1y;
		end
		else if (ps == pipe2) begin
			if (p2x > 0 & p2x < 639)
				x = p2x;
			else
				x = 0;
				
			y = p2y;
		end
		else begin
			x = bx;
			y = by;
		end
	
	end // always_comb
	
	always_ff @(posedge clk) begin
		if (reset)
			ps <= idle;
		else
			ps <= ns; 
	end // always_ff
	
	// use coordinates from last cycle
	always_ff @(posedge clk) begin
		p1x_prev <= pipe1_x; 
		p1y_prev <= pipe1_y;
		p2x_prev <= pipe2_x;
		p2y_prev <= pipe2_y;
		bx_prev <= bird_x;
		by_prev <= bird_y;
	end // always_ff
	
	assign done = bird_done;
	
endmodule // object_clear
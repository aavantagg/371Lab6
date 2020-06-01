module Display_Manager(clk, reset, pipe1_x, pipe1_y, pipe2_x, pipe2_y, bird_x, bird_y, color, x, y);

	input logic clk, reset;
	input logic [10:0] pipe1_x, pipe1_y, pipe2_x, pipe2_y, bird_x, bird_y;
	
	output logic color;
	output logic [10:0] x, y;

	logic pipe1_done, pipe2_done, bird_done, clear_done;
	logic [10:0] p1x, p1y, p2x, p2y, bx, by, clrx, clry;
	logic [9:0] counter;
	
	enum {pipe1, pipe2, bird, clear} ps, ns; 
	
	// cycle between drawing each game object, clear screen at end of cycle
	// CURRENTLY -- cycles between pipe1, pipe2, and clear, add other states as implemented
	always_comb begin
		case (ps)
			pipe1: if (pipe1_done) ns = pipe2;
					 else				  ns = pipe1;
					 
			pipe2: if (pipe2_done & (counter == 1023)) ns = clear;
					 else if (pipe2_done)       ns = pipe1;
					 else				  		       ns = pipe2;
					 
			bird:  if (bird_done)  ns = clear;
					 else				  ns = bird;
					
			clear: if (clear_done) ns = pipe1;
					 else				  ns = clear;
					 
		endcase // ps
	end // always_comb
	
	always_ff @(posedge clk) begin
		if (ps == clear)
			counter <= 0;
		else if (counter != 1023 & (pipe1_done | pipe2_done))
			counter <= counter + 1;
	end 
	
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
	
	// set x and y to coordinates of current object
	always_comb begin
		if (ps == pipe1) begin
			x = p1x;
			y = p1y;
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


module Display_Manager_testbench();

	logic clk, reset;
	logic [10:0] pipe1_x, pipe1_y, pipe2_x, pipe2_y, bird_x, bird_y;
	
	logic color;
	logic [10:0] x, y;
	
	initial begin
		clk <= 0;
		forever #(50) clk <= ~clk;
	end // initial
	
	Display_Manager dut (.*);
	
	initial begin
		reset = 1; pipe1_x = 100; pipe1_y = 380; pipe2_x = 200; pipe2_y = 200; @(posedge clk);
		reset = 0; @(posedge clk);
		
		// clear for a whole lot of cycles, then draw a couple pipes
		for (int i = 0; i < 1000000; i++) begin
			@(posedge clk);
		end
	
		$stop;
	end // initial
endmodule // Display_Manager_testbench
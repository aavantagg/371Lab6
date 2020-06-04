module bird_physics(clk, reset, enable, flap, bird_x, bird_y);
	
	input logic clk, reset, enable, flap;
	output logic [10:0] bird_x, bird_y;
	
	enum {idle, falling1, falling2, falling3, falling4, rising1, rising2, rising3} ps, ns;
	
	logic [2:0] counter;
	
	// next state logic
	always_comb begin
		case (ps)
			idle: if (enable) ns = falling1;
					else			ns = idle;
					
			falling1: if (flap) 				   ns = rising1;
						else if (counter == 4)	ns = falling2;		 
						else						   ns = falling1;
			
			falling2: if (flap) 					ns = rising1;
						 else if (counter == 4) ns = falling3;
						 else							ns = falling2;
			
			falling3: if (flap)					ns = rising1;
						 else if (counter == 4) ns = falling4;
						 else 					   ns = falling3;
						 
			falling4: if (flap) ns = rising1;
						 else		  ns = falling4;
						
			rising1: if (flap) 				  ns = rising1;
						else if (counter == 4) ns = rising2;
						else						  ns = rising1;
						
			rising2: if (flap)				  ns = rising1;
						else if (counter == 4) ns = rising3;
						else						  ns = rising2;
						
			rising3: if (flap)				  ns = rising1;
						else if (counter == 4) ns = falling1;
						else						  ns = rising3;
		
		endcase // ps
	end // always_comb
	
	always_ff @(posedge clk) begin
		if (ps == idle)
			bird_y <= 200;
		else if (ps == falling1)
			bird_y <= bird_y + 1;
		else if (ps == falling2)
			bird_y <= bird_y + 2;
		else if (ps == falling3)
			bird_y <= bird_y + 3;
		else if (ps == falling4)
			bird_y <= bird_y + 5;
		else if (ps == rising1)
			bird_y <= bird_y - 2;
		else if (ps == rising2)
			bird_y <= bird_y - 1;
		
		if (ps != ns)
			counter <= 0;
		else
			counter <= counter + 1;
	end
	
	// update state
	always_ff @(posedge clk) begin
		if (reset | ~enable)
			ps <= idle;
		else
			ps <= ns;
	end // always_ff
	
	// stationary x
	assign bird_x = 150;

endmodule // bird_physics

module bird_physics_testbench();
	logic clk, reset, enable, flap;
	logic [10:0] bird_x, bird_y;
	
	initial begin
		clk <= 0;
		forever #(50) clk <= ~clk;
	end // initial
	
	bird_physics dut (.*);
	
	initial begin
		reset = 1; flap = 0; enable = 0; @(posedge clk);
		reset = 0; @(posedge clk);
		@(posedge clk);
		@(posedge clk);
		
		enable = 1; @(posedge clk);
		@(posedge clk);
		@(posedge clk);
		flap = 1; @(posedge clk);
		flap = 0; @(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		flap = 1; @(posedge clk);
		flap = 0; @(posedge clk);
		@(posedge clk);
		flap = 1; @(posedge clk);
		flap = 0; @(posedge clk);
		flap = 1; @(posedge clk);
		flap = 0; @(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		$stop;
	end

endmodule // bird_physics_testbench
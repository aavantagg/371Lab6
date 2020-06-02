module bird_drawer(clk, reset, start, bird_x, bird_y, done, x, y, color);
	input logic clk, reset, start;
	input logic [10:0] bird_x, bird_y;
	
	output logic color, done;
	output logic [10:0] x, y;
	
	logic [0:33] template [0:23]; 
	logic [7:0] row;
	logic [7:0] col;
	
	initial begin
		$readmemb("C:/Users/casey/OneDrive/Documents/Spring 20/EE 371/Lab6/371Lab6/bird_template_2.txt", template);
	end
	
	enum {s_idle, s_drawing, s_done} ps, ns;
	
	always_comb begin
		case (ps)
			s_idle: if (start) ns = s_drawing;
					  else 		 ns = s_idle;
					  
			s_drawing: if (row == 23 & col == 33) ns = s_done;
						  else				   		  ns = s_drawing;
						  
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
	
	// set row and column of current pixel
	always_ff @(posedge clk) begin
		if (ps == s_idle) begin
			row <= 0;
			col <= 0;
		end // if (s_idle)
		else if (ps == s_drawing) begin
			if (col == 33) begin
				col <= 0;
				row <= row + 1;
			end else
				col <= col + 1;
		end // if (s_drawing)
	end // always_ff
	
	assign color = template[row][col];
	assign x = bird_x + col;
	assign y = bird_y + row;
	assign done = ps == s_done;

endmodule // bird_drawer

module bird_drawer_testbench();
	logic clk, reset, start, color;
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
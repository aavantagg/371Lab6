// Casey Silcox (1629362), August Avantaggio (SID)
// EE 371
// Lab 6: Flappy Bird
// This program...
module DE1_SoC(CLOCK_50, KEY, SW, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, LEDR,
					VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS);

	input logic CLOCK_50;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	
	output logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
	output logic [9:0] LEDR;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;
	
	// coordinates of game objects
	logic [10:0] pipe1_x, pipe1_y, pipe2_x, pipe2_y, bird_x, bird_y;
	// coordinates to draw
	logic [10:0] x, y;
	logic [25:0] divided_clocks;
	logic color, game_clk;
	logic reset;
	
	Display_Manager display (
		.clk			 (CLOCK_50), 
		.reset, 
		.pipe1_x, 
		.pipe1_y, 
		.pipe2_x,
		.pipe2_y,
		.bird_x, 
		.bird_y, 
		.color, 
		.x, 
		.y,
		.clear_en,
		.clear_done);
		
	// temporary
//	assign pipe1_x = 100;
	assign pipe1_y = 250;
//	assign pipe2_x = 400;
	assign pipe2_y = 200;
	assign bird_x = 100;
	assign bird_y = 200;
	
	always_ff @(posedge game_clk) begin
		if (reset) begin
			pipe1_x <= 319;
			pipe2_x <= 639;
		end 
		else if (pipe1_x == 0)
			pipe1_x <= 639;
		else if (pipe2_x == 0)
			pipe2_x <= 639;
		else begin
			pipe1_x <= pipe1_x - 1;
			pipe2_x <= pipe2_x - 1;
		end
	end
	
	logic clear_en, clear_done, clear_lock;
	
	// use clr_en to only clear screen once per game clock
	always_ff @(posedge CLOCK_50) begin
		if (clear_en & clear_done) begin
			clear_en <= 0;
			clear_lock <= 1;
		end
		else if (~game_clk)
			clear_lock <= 0;
		else if (game_clk & ~clear_lock)
			clear_en <= 1;
	end
	
	VGA_framebuffer fb (
		.clk50			 (CLOCK_50), 
		.reset			 (1'b0), 
		.x, 
		.y,
		.pixel_color	 (color), 
		.pixel_write	 (1'b1),
		.VGA_R, 
		.VGA_G, 
		.VGA_B, 
		.VGA_CLK, 
		.VGA_HS, 
		.VGA_VS,
		.VGA_BLANK_n	 (VGA_BLANK_N), 
		.VGA_SYNC_n		 (VGA_SYNC_N));

	
	// set up clock divider and game clock
	always_ff @(posedge CLOCK_50) begin
		divided_clocks = divided_clocks + 1;
	end
	assign game_clk = divided_clocks[19];
	
	assign HEX5 = 7'b1111111;
	assign HEX4 = 7'b1111111;
	assign HEX3 = 7'b1111111;
	assign HEX2 = 7'b1111111;
	assign HEX1 = 7'b1111111;
	assign HEX0 = 7'b1111111;
	assign LEDR[9:0] = 10'b0;
	assign reset = SW[0];
endmodule


// Casey Silcox (1629362), August Avantaggio (SID)
// EE 371
// Lab 6: Flappy Bird
// This program...
module DE1_SoC(CLOCK_50, KEY, SW, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, LEDR,
					VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS,
               PS2_DAT, PS2_CLK, CLOCK2_50, FPGA_I2C_SCLK, FPGA_I2C_SDAT, AUD_ADCDAT,
               AUD_ADCLRCK, AUD_BCLK, AUD_DACDAT, AUD_DACLRCK, AUD_XCK);

	input logic CLOCK_50;
	input logic [3:0] KEY;
	input logic [9:0] SW;

   input PS2_DAT;
   input PS2_CLK;
		
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
	
	logic reset;
	logic [10:0] x, y;

	// coordinates of game objects
	logic [10:0] pipe1_x, pipe1_y, pipe2_x, pipe2_y, bird_x, bird_y;
	
	logic [25:0] divided_clocks;
	logic color, game_clk;
	logic flap, collision, game_enable, restart, game_reset;
	
	// Set pipe coordinates
	always_ff @(posedge game_clk) begin
		if (reset | restart) begin
			pipe1_x <= 319;
			pipe2_x <= 639;
            pipe1_y <= 250 + random[7:0];
            pipe2_y <= 200 + random[7:0];
		end 
		else if (pipe1_x == 0) begin
			pipe1_x <= 639;
            pipe1_y <= 250 + random[7:0];
        end else if (pipe2_x == 0) begin
			pipe2_x <= 639;
            pipe2_y <= 200 + random[7:0];
        end else if (game_enable) begin
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
	
	// will be replaced by keyboard (except reset)
    always_ff @(posedge CLOCK_50) begin
        if (makeBreak && key == 8'h2D) restart <= 1; // r
        else restart <= 0;
        if (makeBreak && key == 8'h2B) flap <= 1; 	// f
        else flap <= 0;
    end // always_ff
    
	assign reset = ~KEY[0];

   logic valid;
   logic makeBreak;
   logic [7:0] key;

   logic [9:0] random; // 10-bit pseudorandom number

   LFSR rand_height (.clk(CLOCK_50),
                     .rst(reset),
                     .out(random));
						  
   score_manager my_score (.reset,
                            .clock(game_clk),
                            .restart,
                            .collision,
                            .bird_x,
                            .pipe1_x,
                            .pipe2_x,
                            .score_digits({HEX5,HEX4,HEX3,HEX2,HEX1,HEX0}),
                            );

    keyboard_press_driver keyboard (    .CLOCK_50,
                                        .valid,
                                        .makeBreak,
                                        .outCode(key),
                                        .PS2_DAT,
                                        .PS2_CLK,
                                        .reset
                                    );
	
	game_manager control (.clk					(CLOCK_50), 
								 .reset, 
								 .flap, 
								 .collision, 
								 .restart, 
								 .game_enable);
								 
	collision_detector checkForDead (.clk			(CLOCK_50), 
												.reset, 
												.bird_x, 
												.bird_y, 
												.pipe1_x, 
												.pipe1_y, 
												.pipe2_x, 
												.pipe2_y, 
												.restart, 
												.collision);
	
	
	display_manager display (.clk			 (CLOCK_50), 
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
		
	bird_physics bird_height (.clk		 (game_clk), 
									  .reset		 (reset | game_reset), 
									  .enable	 (game_enable),
									  .restart,
									  .collision, 
									  .flap, 
									  .bird_x, 
									  .bird_y);

	// set up clock divider and game clock
	always_ff @(posedge CLOCK_50) begin
		divided_clocks = divided_clocks + 1;
	end
	
	assign game_clk = divided_clocks[19];
	
	assign LEDR[7:0] = 10'b0;
   assign LEDR[8] = bird_x == pipe1_x || bird_x == pipe2_x;
	assign LEDR[9] = collision;

   // Audio

   input CLOCK2_50;
   output FPGA_I2C_SCLK;
	inout FPGA_I2C_SDAT;
	output AUD_XCK;
	input AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input AUD_ADCDAT;
	output AUD_DACDAT;
	
	wire read_ready, write_ready, read, write;
	wire [23:0] readdata_left, readdata_right;
	wire [23:0] writedata_left, writedata_right;

    always_comb begin
        if (collision) begin
            writedata_left = 24'b0;
            writedata_right = 24'b0;
        end else begin 
            writedata_left = readdata_left;
	        writedata_right = readdata_right;
        end
    end // always_comb

	assign read = read_ready;
	assign write = write_ready; 
	
	clock_generator my_clock_gen(
		CLOCK2_50,
		reset,
		AUD_XCK
	);

	audio_and_video_config cfg(
		CLOCK_50,
		reset,
		FPGA_I2C_SDAT,
		FPGA_I2C_SCLK
	);

	audio_codec codec(
		CLOCK_50,
		reset,
		read,	
		write,
		writedata_left, 
		writedata_right,
		AUD_ADCDAT,
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,
		read_ready, write_ready,
		readdata_left, readdata_right,
		AUD_DACDAT
	);
	
endmodule // DE1_SoC


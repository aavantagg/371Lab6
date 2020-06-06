// Super simple FSM to choose when the game resets and plays
module game_manager(clk, reset, flap, collision, restart, game_enable, game_reset);
	
	input logic clk, reset, flap, restart, collision;
	output logic game_enable, game_reset;
	
	enum {ready, playing, done} ps, ns;
	
	always_comb begin
		case (ps)
			ready: if (flap) ns = playing;
					 else		  ns = ready;
					 
			playing: if (collision) ns = done;
						else				ns = playing;
						
			done: if (restart) ns = ready;
					else			 ns = done;
		endcase
	end
	
	always_ff @(posedge clk) begin
		if (reset)
			ps <= ready;
		else
			ps <= ns;
	end

	assign game_enable = ps == playing;
	assign game_reset = (ps == done) & (ns == ready);

endmodule // game manager
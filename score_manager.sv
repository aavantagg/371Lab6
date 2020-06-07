module score_manager (  input logic reset,
                        input logic clock,
                        input logic game_reset,
                        input logic [10:0] bird_x,
                        input logic [10:0] bird_y,
                        input logic [10:0] pipe1_x,
                        input logic [10:0] pipe1_y,
                        input logic [10:0] pipe2_x,
                        input logic [10:0] pipe2_y,
                        output logic [7:0] score,
                        output logic new_highscore,
                        output logic gameover
                    );

    logic [7:0] highscore;

    always_ff @(posedge clock) begin
        if (reset) begin
            score <= 8'b0;
            new_highscore <= 0;
            highscore <= 8'b0;
            gameover <= 0;
        end else if (game_reset) begin
            score <= 8'b0;
            new_highscore <= 0;
            gameover <= 0;
        end
        // if (scoring condition)
        //     score <= score + 1;
        // else
        //     if (score > highscore)
        //         new_highscore <= 1;
        //         gameover <= 1;
    end // always_ff

    always_comb begin
        if (bird_x == pipe1_x) begin
            if ()
    end // always_comb
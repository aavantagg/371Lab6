module score_manager (  input logic reset,
                        input logic clock,
                        input logic restart,
                        input logic collision,
                        input logic [10:0] bird_x,
                        input logic [10:0] bird_y,
                        input logic [10:0] pipe1_x,
                        input logic [10:0] pipe1_y,
                        input logic [10:0] pipe2_x,
                        input logic [10:0] pipe2_y,
                        output logic [41:0] score_digits
                    );

    logic gameover;
    logic [7:0] score,
    logic new_highscore,
    logic [7:0] highscore;

    always_ff @(posedge clock) begin
        if (reset) begin
            score <= 8'b0;
            new_highscore <= 0;
            highscore <= 8'b0;
            gameover <= 0;
        end else if (restart) begin
            score <= 8'b0;
            new_highscore <= 0;
            gameover <= 0;
        end
        if (collision | gameover)
            if (score > highscore) 
                new_highscore <= 1;
                highscore <= score;

            gameover <= 1;
        else if (bird_x == pipe1_x || bird_x - pipe2_x)
            score <= score + 1;

    end // always_ff

    always_comb begin
        if (bird_x == pipe1_x) begin
            if ()
    end // always_comb

    score_display high_hundreds (   .digit(highscore / 100),
                                    .seg7(score_digits[41:35])
                                );

    score_display high_tens     (   .digit(highscore / 10),
                                    .seg7(score_digits[34:28])
                                );

    score_display high_ones     (   .digit(highscore % 10),
                                    .seg7(score_digits[27:21])
                                );

    score_display hundreds  (   .digit(score / 100),
                                .seg7(score_digits[20:14])
                            );
            
    score_display tens      (   .digit(score / 10),
                                .seg7(score_digits[13:7])
                            );

    score_display ones      (   .digit(score % 10),
                                .seg7(score_digits[6:0])
                            );

endmodule // score_manager
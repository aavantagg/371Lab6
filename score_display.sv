// Module that outputs 7-segment display values for the 16 hex digits.
// 
// Inputs:
// 4-bit digit: Binary representation of the number to be displayed in hex.
//
// Output:
// 7-bit seg7: 7-segment display value.
module display
            (   input logic [3:0] digit,
                output logic [6:0] seg7
            );

    logic [6:0] digits [15:0];

    initial begin
        // Display values for hex digits
        digits[0] = 7'b1000000;
        digits[1] = 7'b1111001;
        digits[2] = 7'b0100100;
        digits[3] = 7'b0110000;
        digits[4] = 7'b0011001;
        digits[5] = 7'b0010010;
        digits[6] = 7'b0000010;
        digits[7] = 7'b1111000;
        digits[8] = 7'b0000000;
        digits[9] = 7'b0011000;
        digits[10] = 7'b0001000;
        digits[11] = 7'b0000011;
        digits[12] = 7'b1000110;
        digits[13] = 7'b0100001;
        digits[14] = 7'b0000110;
        digits[15] = 7'b0001110;
    end // initial

    assign seg7 = digits[digit];

endmodule
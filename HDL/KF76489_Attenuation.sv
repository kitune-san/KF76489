//
// KF76489_Attenuation
// Attenuation Table
//
// Written by Kitune-san
//
module KF76489_Attenuation (
    input   logic   [3:0]   attenuation,
    input   logic           digital_in,
    output  logic   [5:0]   analog_out
);

    always_comb begin
        casez ({digital_in, attenuation})
            //A3210
            5'b10000: analog_out = 6'd63;
            5'b11000: analog_out = 6'd50;
            5'b10100: analog_out = 6'd40;
            5'b11100: analog_out = 6'd32;
            5'b10010: analog_out = 6'd25;
            5'b11010: analog_out = 6'd20;
            5'b10110: analog_out = 6'd16;
            5'b11110: analog_out = 6'd13;
            5'b10001: analog_out = 6'd10;
            5'b11001: analog_out = 6'd8;
            5'b10101: analog_out = 6'd6;
            5'b11101: analog_out = 6'd5;
            5'b10011: analog_out = 6'd4;
            5'b11011: analog_out = 6'd3;
            5'b10111: analog_out = 6'd2;
            5'b11111: analog_out = 6'd0;
            default:  analog_out = 6'd0;
        endcase
    end

endmodule


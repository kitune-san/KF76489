//
// KF76489_Invert_AOUT
//
// Written by Kitune-san
//
module KF76489_Invert_AOUT (
    input   logic   [7:0]   AOUT_in,
    output  logic   [7:0]   AOUT_out
);

    assign  AOUT_out = ~AOUT_in;

endmodule


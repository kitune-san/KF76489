//
// KF76489_Noise_Generator
// Noise Generator
//
// Written by Kitune-san
//
module KF76489_Noise_Generator (
    input   logic           clock,
    input   logic           clock_enable,
    input   logic           reset,

    input   logic   [7:0]   internal_data_bus,
    input   logic           write_noise_control,
    input   logic           write_noise_attenuation,

    input   logic           ext_noise_gen,
    output  logic   [5:0]   analog_out
);

    //
    // Registers
    //
    logic           feedback;
    logic   [1:0]   shift_rate;
    logic   [3:0]   attenuation;

    // Feedback Control Register
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            feedback            <= 1'b0;
        else if (write_noise_control)
            feedback            <= internal_data_bus[5];
        else
            feedback            <= feedback;
    end

    // Shift Rate Register
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            shift_rate          <= 2'b00;
        else if (write_noise_control)
            shift_rate          <= internal_data_bus[7:6];
        else
            shift_rate          <= shift_rate;
    end

    // Attenuation Register
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            attenuation         <= 4'h0;
        else if (write_noise_attenuation)
            attenuation         <= internal_data_bus[7:4];
        else
            attenuation         <= attenuation;
    end

    //
    // Clock divider
    //
    logic   [3:0]   divider_count;
    logic           divided_clock_tap0_en;
    logic           divided_clock_tap1;
    logic           divided_clock_tap1_en;
    logic           divided_clock_tap2;
    logic           divided_clock_tap2_en;
    logic           divided_clock_tap3;
    logic           divided_clock_tap3_en;

    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            divider_count       <= 4'h0;
        else if (clock_enable)
            divider_count       <= divider_count + 4'h1;
        else
            divider_count       <= divider_count;
    end
    assign  divided_clock_tap0_en = (&divider_count) ? 1'b1 : 1'b0;

    // Tap1 (N/512)
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            divided_clock_tap1  <= 1'b0;
        else if (divided_clock_tap0_en)
            divided_clock_tap1  <= ~divided_clock_tap1;
        else
            divided_clock_tap1  <=  divided_clock_tap1;
    end
    assign  divided_clock_tap1_en = divided_clock_tap0_en & ~divided_clock_tap1;

    // Tap2 (N/1024)
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            divided_clock_tap2  <= 1'b0;
        else if (divided_clock_tap1_en)
            divided_clock_tap2  <= ~divided_clock_tap2;
        else
            divided_clock_tap2  <=  divided_clock_tap2;
    end
    assign  divided_clock_tap2_en = divided_clock_tap1_en & ~divided_clock_tap2;

    // Tap3 (N/2048)
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            divided_clock_tap3  <= 1'b0;
        else if (divided_clock_tap2_en)
            divided_clock_tap3  <= ~divided_clock_tap3;
        else
            divided_clock_tap3  <=  divided_clock_tap3;
    end
    assign  divided_clock_tap3_en = divided_clock_tap2_en & ~divided_clock_tap3;


    //
    // Shift Rate Select
    //
    logic   shift;
    always_comb begin
        casez (shift_rate)
           //NF10
            2'b00:   shift  = divided_clock_tap1_en;
            2'b10:   shift  = divided_clock_tap2_en;
            2'b01:   shift  = divided_clock_tap3_en;
            2'b11:   shift  = ext_noise_gen;
            default: shift  = 1'b0;
        endcase
    end


    //
    // Noise Generator
    //
    // Periodic noise
    logic   [14:0]  periodic_shift_register;
    logic           periodic_noise;
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            periodic_shift_register <= 15'b100000000000000;
        else if (write_noise_control)
            periodic_shift_register <= 15'b100000000000000;
        else if (shift)
            periodic_shift_register <= {periodic_shift_register[0], periodic_shift_register[14:1]};
        else
            periodic_shift_register <= periodic_shift_register;
    end
    assign  periodic_noise = periodic_shift_register[0];

    // White noise
    logic   [14:0]  white_shift_register;
    logic           white_noise;
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            white_shift_register    <= 15'b100000000000000;
        else if (write_noise_control)
            white_shift_register    <= 15'b100000000000000;
        else if (shift)
            white_shift_register    <= {(white_shift_register[4] ^ white_shift_register[0]), white_shift_register[14:1]};
        else
            white_shift_register    <= white_shift_register;
    end
    assign  white_noise = white_shift_register[0];

    // Noise select
    wire    noise = (feedback) ? white_noise : periodic_noise;


    //
    // Analog out
    //
    KF76489_Attenuation u_Attenuation (
        .attenuation        (attenuation),
        .digital_in         (noise),
        .analog_out         (analog_out)
    );

endmodule


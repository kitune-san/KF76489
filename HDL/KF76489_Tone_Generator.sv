//
// KF76489_Tone_Generator
// Tone Generator
//
// Written by Kitune-san
//
module KF76489_Tone_Generator (
    input   logic           clock,
    input   logic           clock_enable,
    input   logic           reset,

    input   logic   [7:0]   internal_data_bus,
    input   logic           write_frequency_h,
    input   logic           write_frequency_l,
    input   logic           write_attenuation,

    output  logic           cycle_out,
    output  logic   [5:0]   analog_out
);

    //
    // Registers
    //
    logic   [9:0]   frequency;
    logic   [3:0]   attenuation;

    // Frequency Register
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            frequency       <= 10'h000;
        else if (write_frequency_h)
            frequency       <= {internal_data_bus[7:4], frequency[5:0]};
        else if (write_frequency_l)
            frequency       <= {frequency[9:6], internal_data_bus[7:2]};
        else
            frequency       <= frequency;
    end

    // Attenuation Register
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            attenuation     <= 4'hF;
        else if (write_attenuation)
            attenuation     <= internal_data_bus[7:4];
        else
            attenuation     <= attenuation;
    end


    //
    // Clock divider (/N)
    //
    logic   [9:0]   divider_count;
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            divider_count   <= 10'h1;
        else if (~clock_enable)
            divider_count   <= divider_count;
        else if (~|divider_count)
            divider_count   <= ((~|frequency) ? 10'h1 : frequency) - 10'h1;
        else
            divider_count   <= divider_count - 10'h1;
    end


    //
    // Digital Out (/2)
    //
    logic           digital_out;
    always_ff @(posedge clock, posedge reset) begin
        if (reset) begin
            digital_out     <= 1'b0;
        end
        else if ((clock_enable) && (~|divider_count)) begin
            digital_out     <= ~digital_out;
            cycle_out       <= 1'b1;
        end
        else begin
            digital_out     <= digital_out;
            cycle_out       <= 1'b0;
        end
    end


    //
    // Analog out
    //
    KF76489_Attenuation u_Attenuation (
        .attenuation        (attenuation),
        .digital_in         (digital_out),
        .analog_out         (analog_out)
    );

endmodule


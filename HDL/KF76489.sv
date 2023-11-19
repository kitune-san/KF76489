//
// KF76489
// Digital Complex Sound generator
//
// Written by Kitune-san
//
module KF76489 (
    input   logic           clock,
    input   logic           clock_enable,
    input   logic           reset,

    input   logic           CE_N,
    input   logic           WE_N,
    input   logic   [7:0]   D_IN,

    output  logic           READY,
    output  logic   [7:0]   AOUT
);

    //
    // Internal Signals
    //
    logic   [3:0]   clock_divider_count;
    logic           divided_clock_en;
    logic   [7:0]   internal_data_bus;
    logic           write_tone1_frequency_h;
    logic           write_tone1_frequency_l;
    logic           write_tone1_attenuation;
    logic           write_tone2_frequency_h;
    logic           write_tone2_frequency_l;
    logic           write_tone2_attenuation;
    logic           write_tone3_frequency_h;
    logic           write_tone3_frequency_l;
    logic           write_tone3_attenuation;
    logic           write_noise_control;
    logic           write_noise_attenuation;
    logic           ext_noise_gen;
    logic   [5:0]   tone1_aout;
    logic   [5:0]   tone2_aout;
    logic   [5:0]   tone3_aout;
    logic   [5:0]   noise_aout;

    //
    // Data Bus Buffer & Read/Write Control Logic
    //
    KF76489_Bus_Control_Logic u_Bus_Control_Logic (
        .clock                      (clock),
        .reset                      (reset),
        .CE_N                       (CE_N),
        .WE_N                       (WE_N),
        .D_IN                       (D_IN),
        .internal_data_bus          (internal_data_bus),
        .write_tone1_frequency_h    (write_tone1_frequency_h),
        .write_tone1_frequency_l    (write_tone1_frequency_l),
        .write_tone1_attenuation    (write_tone1_attenuation),
        .write_tone2_frequency_h    (write_tone2_frequency_h),
        .write_tone2_frequency_l    (write_tone2_frequency_l),
        .write_tone2_attenuation    (write_tone2_attenuation),
        .write_tone3_frequency_h    (write_tone3_frequency_h),
        .write_tone3_frequency_l    (write_tone3_frequency_l),
        .write_tone3_attenuation    (write_tone3_attenuation),
        .write_noise_control        (write_noise_control),
        .write_noise_attenuation    (write_noise_attenuation)
    );

    //
    // Clock divider (/16)
    //
    always_ff @(posedge clock, posedge reset) begin
        if (reset) begin
            clock_divider_count <= 4'h0;
            divided_clock_en    <= 1'b0;
        end
        else if (clock_enable) begin
            clock_divider_count <= clock_divider_count + 4'h1;
            divided_clock_en    <= (&clock_divider_count) ? 1'b1 : 1'b0;
        end
        else begin
            clock_divider_count <= clock_divider_count;
            divided_clock_en    <= 1'b0;
        end
    end

    //
    // Tone 1
    //
    KF76489_Tone_Generator u_Tone1 (
        .clock                      (clock),
        .clock_enable               (divided_clock_en),
        .reset                      (reset),
        .internal_data_bus          (internal_data_bus),
        .write_frequency_h          (write_tone1_frequency_h),
        .write_frequency_l          (write_tone1_frequency_l),
        .write_attenuation          (write_tone1_attenuation),
        //.cycle_out                  (),
        .analog_out                 (tone1_aout)
    );

    //
    // Tone 2
    //
    KF76489_Tone_Generator u_Tone2 (
        .clock                      (clock),
        .clock_enable               (divided_clock_en),
        .reset                      (reset),
        .internal_data_bus          (internal_data_bus),
        .write_frequency_h          (write_tone2_frequency_h),
        .write_frequency_l          (write_tone2_frequency_l),
        .write_attenuation          (write_tone2_attenuation),
        //.cycle_out                  (),
        .analog_out                 (tone2_aout)
    );

    //
    // Tone 3
    //
    KF76489_Tone_Generator u_Tone3 (
        .clock                      (clock),
        .clock_enable               (divided_clock_en),
        .reset                      (reset),
        .internal_data_bus          (internal_data_bus),
        .write_frequency_h          (write_tone3_frequency_h),
        .write_frequency_l          (write_tone3_frequency_l),
        .write_attenuation          (write_tone3_attenuation),
        .cycle_out                  (ext_noise_gen),
        .analog_out                 (tone3_aout)
    );

    //
    // Noise
    //
    KF76489_Noise_Generator u_Noise (
        .clock                      (clock),
        .clock_enable               (divided_clock_en),
        .reset                      (reset),
        .internal_data_bus          (internal_data_bus),
        .write_noise_control        (write_noise_control),
        .write_noise_attenuation    (write_noise_attenuation),
        .ext_noise_gen              (ext_noise_gen),
        .analog_out                 (noise_aout)
    );

    //
    // Mixer
    //
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            AOUT <= 1'b0;
        else
            AOUT <= {2'b0, tone1_aout} + {2'b0, tone2_aout} + {2'b0, tone3_aout} + {2'b0, noise_aout};
    end

endmodule


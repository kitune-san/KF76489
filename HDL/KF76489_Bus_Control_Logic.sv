//
// KF76489_Bus_Control_Logic
// Data Bus Buffer & Read/Write Control Logic
//
// Written by Kitune-san
//
module KF76489_Bus_Control_Logic (
    input   logic           clock,
    input   logic           reset,

    input   logic           CE_N,
    input   logic           WE_N,
    input   logic   [7:0]   D_IN,

    output  logic   [7:0]   internal_data_bus,
    output  logic           write_tone1_frequency_h,
    output  logic           write_tone1_frequency_l,
    output  logic           write_tone1_attenuation,
    output  logic           write_tone2_frequency_h,
    output  logic           write_tone2_frequency_l,
    output  logic           write_tone2_attenuation,
    output  logic           write_tone3_frequency_h,
    output  logic           write_tone3_frequency_l,
    output  logic           write_tone3_attenuation,
    output  logic           write_noise_control,
    output  logic           write_noise_attenuation
);


    //
    // Internal Signals
    //
    logic           prev_write_enable_n;
    logic           write_flag;
    logic   [3:0]   stable_address;
    logic   [3:0]   prev_stable_address;


    //
    // Write Control
    //
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            prev_write_enable_n <= 1'b1;
        else if (CE_N)
            prev_write_enable_n <= 1'b1;
        else
            prev_write_enable_n <= WE_N;
    end
    assign write_flag = ~prev_write_enable_n & WE_N;

    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            internal_data_bus   <= 8'h00;
        else
            internal_data_bus   <= D_IN;
    end
    assign  stable_address = internal_data_bus[3:0];

    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            prev_stable_address <= 4'b000;
        else if (write_flag)
            prev_stable_address <= stable_address;
        else
            prev_stable_address <= prev_stable_address;
    end
                                                                                                //R210
    assign  write_tone1_frequency_h = write_flag &  stable_address[0] & (stable_address[3:1] == 3'b000);
    assign  write_tone1_frequency_l = write_flag & ~stable_address[0] & (prev_stable_address == 4'b0001);
    assign  write_tone1_attenuation = write_flag &  stable_address[0] & (stable_address[3:1] == 3'b100);
    assign  write_tone2_frequency_h = write_flag &  stable_address[0] & (stable_address[3:1] == 3'b010);
    assign  write_tone2_frequency_l = write_flag & ~stable_address[0] & (prev_stable_address == 4'b0101);
    assign  write_tone2_attenuation = write_flag &  stable_address[0] & (stable_address[3:1] == 3'b110);
    assign  write_tone3_frequency_h = write_flag &  stable_address[0] & (stable_address[3:1] == 3'b001);
    assign  write_tone3_frequency_l = write_flag & ~stable_address[0] & (prev_stable_address == 4'b0011);
    assign  write_tone3_attenuation = write_flag &  stable_address[0] & (stable_address[3:1] == 3'b101);
    assign  write_noise_control     = write_flag &  stable_address[0] & (stable_address[3:1] == 3'b011);
    assign  write_noise_attenuation = write_flag &  stable_address[0] & (stable_address[3:1] == 3'b111);

endmodule


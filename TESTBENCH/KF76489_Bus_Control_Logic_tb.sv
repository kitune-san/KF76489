
`define TB_CYCLE        20
`define TB_FINISH_COUNT 20000

module tb();

    timeunit        1ns;
    timeprecision   10ps;

    //
    // Generate wave file to check
    //
`ifdef IVERILOG
    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
    end
`endif

    //
    // Generate clock
    //
    logic   clock;
    initial clock = 1'b0;
    always #(`TB_CYCLE / 2) clock = ~clock;

    //
    // Generate reset
    //
    logic reset;
    initial begin
        reset = 1'b1;
            # (`TB_CYCLE * 10)
        reset = 1'b0;
    end

    //
    // Cycle counter
    //
    logic   [31:0]  tb_cycle_counter;
    always_ff @(negedge clock, posedge reset) begin
        if (reset)
            tb_cycle_counter <= 32'h0;
        else
            tb_cycle_counter <= tb_cycle_counter + 32'h1;
    end

    always_comb begin
        if (tb_cycle_counter == `TB_FINISH_COUNT) begin
            $display("***** SIMULATION TIMEOUT ***** at %d", tb_cycle_counter);
`ifdef IVERILOG
            $finish;
`elsif MODELSIM
            $stop;
`else
            $finish;
`endif
        end
    end

    //
    // Module under test
    //
    logic           CE_N;
    logic           WE_N;
    logic   [7:0]   D_IN;
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

    KF76489_Bus_Control_Logic u_Bus_Control_Logic (.*);

    //
    // Task : Initialization
    //
    task TASK_INIT();
    begin
        #(`TB_CYCLE * 0);
        WE_N            = 1'b1;
        CE_N            = 1'b1;
        D_IN            = 8'hFF;
        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // Task : Write data
    //
    task TASK_WRITE_DATA(input [7:0] data);
    begin
        #(`TB_CYCLE * 0);
        CE_N            = 1'b0;
        WE_N            = 1'b0;
        D_IN            = data;
        #(`TB_CYCLE * 1);
        WE_N            = 1'b1;
        CE_N            = 1'b1;
        #(`TB_CYCLE * 1);
    end
    endtask

    //
    // Test pattern
    //
    initial begin
        TASK_INIT();
        // Write Tone 1 Frequency
        TASK_WRITE_DATA(8'b0101_000_1);
        TASK_WRITE_DATA(8'b0101010_0);
        // Write Tone 1 Atteniation
        TASK_WRITE_DATA(8'b1010_100_1);

        // Write Tone 2 Frequency
        TASK_WRITE_DATA(8'b1010_010_1);
        TASK_WRITE_DATA(8'b1010100_0);
        // Write Tone 2 Atteniation
        TASK_WRITE_DATA(8'b0101_110_1);

        // Write Tone 3 Frequency
        TASK_WRITE_DATA(8'b1111_001_1);
        TASK_WRITE_DATA(8'b0000000_0);
        // Write Tone 3 Atteniation
        TASK_WRITE_DATA(8'b0011_101_1);

        // Write Noise Control
        TASK_WRITE_DATA(8'b1100_011_1);
        // Write Noise Atteniation
        TASK_WRITE_DATA(8'b1001_111_1);

        // End of simulation
`ifdef IVERILOG
        $finish;
`elsif  MODELSIM
        $stop;
`else
        $finish;
`endif
    end

endmodule


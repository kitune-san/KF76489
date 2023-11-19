
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
    logic           clock_enable;
    logic   [7:0]   internal_data_bus;
    logic           write_frequency_h;
    logic           write_frequency_l;
    logic           write_attenuation;
    logic           cycle_out;
    logic   [5:0]   analog_out;

    KF76489_Tone_Generator u_Tone_Generator (.*);

    logic   [7:0]   counter;
    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            counter     <= 8'd3;
        else if (~|counter)
            counter     <= 8'd3;
        else
            counter     <= counter - 8'd1;
    end
    assign  clock_enable = ~|counter;

    //
    // Task : Initialization
    //
    task TASK_INIT();
    begin
        #(`TB_CYCLE * 0);
        internal_data_bus   = 8'h00;
        write_frequency_h   = 1'b0;
        write_frequency_l   = 1'b0;
        write_attenuation   = 1'b0;
        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // Task : Write Frequency
    //
    task TASK_WRITE_FREQUENCY(input [9:0] data);
    begin
        #(`TB_CYCLE * 0);
        write_frequency_h   = 1'b1;
        internal_data_bus   = {data[9:6], 4'b0000};
        #(`TB_CYCLE * 1);
        write_frequency_h   = 1'b0;
        #(`TB_CYCLE * 1);
        write_frequency_l   = 1'b1;
        internal_data_bus   = {data[5:0],   2'b00};
        #(`TB_CYCLE * 1);
        write_frequency_l   = 1'b0;
        #(`TB_CYCLE * 1);
    end
    endtask

    task TASK_WRITE_ATTENUATION(input [3:0] data);
    begin
        #(`TB_CYCLE * 0);
        write_attenuation   = 1'b1;
        internal_data_bus   = {data[0], data[1], data[2], data[3], 4'b0000};
        #(`TB_CYCLE * 1);
        write_attenuation   = 1'b0;
        #(`TB_CYCLE * 1);
    end
    endtask

    //
    // Test pattern
    //
    initial begin
        TASK_INIT();
        TASK_WRITE_ATTENUATION(4'h0);
        TASK_WRITE_FREQUENCY(10'd10);
        #(`TB_CYCLE * 100);
        TASK_WRITE_FREQUENCY(10'd32);
        #(`TB_CYCLE * 1000);
        TASK_WRITE_FREQUENCY(10'd10);
        #(`TB_CYCLE * 100);
        TASK_WRITE_ATTENUATION(4'd0);
        #(`TB_CYCLE * 100);
        TASK_WRITE_ATTENUATION(4'd1);
        #(`TB_CYCLE * 100);
        TASK_WRITE_ATTENUATION(4'd2);
        #(`TB_CYCLE * 100);
        TASK_WRITE_ATTENUATION(4'd3);
        #(`TB_CYCLE * 100);
        TASK_WRITE_ATTENUATION(4'd4);
        #(`TB_CYCLE * 100);
        TASK_WRITE_ATTENUATION(4'd5);
        #(`TB_CYCLE * 100);
        TASK_WRITE_ATTENUATION(4'd6);
        #(`TB_CYCLE * 100);
        TASK_WRITE_ATTENUATION(4'd7);
        #(`TB_CYCLE * 100);
        TASK_WRITE_ATTENUATION(4'd8);
        #(`TB_CYCLE * 100);
        TASK_WRITE_ATTENUATION(4'd9);
        #(`TB_CYCLE * 100);
        TASK_WRITE_ATTENUATION(4'd10);
        #(`TB_CYCLE * 100);
        TASK_WRITE_ATTENUATION(4'd11);
        #(`TB_CYCLE * 100);
        TASK_WRITE_ATTENUATION(4'd12);
        #(`TB_CYCLE * 100);
        TASK_WRITE_ATTENUATION(4'd13);
        #(`TB_CYCLE * 100);
        TASK_WRITE_ATTENUATION(4'd14);
        #(`TB_CYCLE * 100);
        TASK_WRITE_ATTENUATION(4'd15);
        #(`TB_CYCLE * 100);
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


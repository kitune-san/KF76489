
`define TB_CYCLE        20
`define TB_FINISH_COUNT 200000

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
    logic           CE_N;
    logic           WE_N;
    logic   [7:0]   D_IN;
    logic           READY;
    logic   [7:0]   AOUT;

    KF76489 u_76489 (.*);

    always_ff @(posedge clock, posedge reset) begin
        if (reset)
            clock_enable    <= 1'b0;
        else
            clock_enable    <= ~clock_enable;
    end


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
        #(`TB_CYCLE * 64);
        WE_N            = 1'b1;
        CE_N            = 1'b1;
        #(`TB_CYCLE * 1);
    end
    endtask

    //
    // Task : Write Tone_N Frequency
    //
    logic   [9:0]   inv_data;
    task TASK_WRITE_FREQUENCY(input [2:0] addr, input [9:0] data);
    begin
        #(`TB_CYCLE * 0);
        inv_data = {data[0], data[1], data[2], data[3], data[4],
                    data[5], data[6], data[7], data[8], data[9]};
        TASK_WRITE_DATA({inv_data[9:6], addr[0], addr[1], addr[2], 1'b1});
        #(`TB_CYCLE * 1);
        TASK_WRITE_DATA({inv_data[5:0], 2'b00});
        #(`TB_CYCLE * 1);
    end
    endtask

    //
    // Task : Write Tone_N / noise Attenuation
    //
    task TASK_WRITE_ATTENUATION(input [2:0] addr, input [3:0] data);
    begin
        #(`TB_CYCLE * 0);
        TASK_WRITE_DATA({data[0], data[1], data[2], data[3], addr[0], addr[1], addr[2], 1'b1});
        #(`TB_CYCLE * 1);
    end
    endtask

    //
    // Task : Write noise control
    //
    task TASK_WRITE_NOISE_CONTROL(input [2:0] addr, input fb, input [1:0] nf);
    begin
        #(`TB_CYCLE * 0);
        TASK_WRITE_DATA({nf, fb, 1'b0, addr[0], addr[1], addr[2], 1'b1});
        #(`TB_CYCLE * 1);
    end
    endtask

    //
    // Test pattern
    //
    initial begin
        TASK_INIT();
        //
        // Tone 0:
        // Frequency    = 10;
        // Attenuation  = 0;
        //
        TASK_WRITE_FREQUENCY  (3'b000, 10'd10);
        TASK_WRITE_ATTENUATION(3'b001, 4'd0);
        #(`TB_CYCLE * 10000);

        //
        // Tone 2:
        // Frequency    = 32;
        // Attenuation  = 5;
        //
        TASK_WRITE_FREQUENCY  (3'b010, 10'd32);
        TASK_WRITE_ATTENUATION(3'b011, 4'd5);
        #(`TB_CYCLE * 10000);

        //
        // Tone 3:
        // Frequency    = 0;
        // Attenuation  = 10;
        //
        TASK_WRITE_FREQUENCY  (3'b100, 10'd0);
        TASK_WRITE_ATTENUATION(3'b101, 4'd10);
        #(`TB_CYCLE * 10000);

        //
        // Noise:
        // FB   = 0; (Periodic)
        // NF   = 11 (tone_3)
        // Attenuation  = 1;
        //
        TASK_WRITE_NOISE_CONTROL(3'b110, 1'b0, 2'b11);
        TASK_WRITE_ATTENUATION  (3'b111, 4'd1);
        #(`TB_CYCLE * 10000);

        //
        // Noise:
        // FB   = 1; (White)
        // NF   = 00 (N/512)
        // Attenuation  = 0;
        //
        TASK_WRITE_NOISE_CONTROL(3'b110, 1'b1, 2'b00);
        TASK_WRITE_ATTENUATION  (3'b111, 4'd0);
        #(`TB_CYCLE * 100000);

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


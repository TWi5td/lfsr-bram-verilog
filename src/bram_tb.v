`timescale 1ns / 1ps

module bram_tb;
    reg clk_125MHz;
    reg clk_10MHz;
    reg reset;
    reg bram_write_enable;
    wire [3:0] lfsr_out;
    wire [3:0] bram_out;

    LFSR lfsr_inst (.clk(clk_10MHz), .reset(reset), .lfsr_out(lfsr_out));
    bram_interface uut (.clk_125MHz(clk_125MHz), .clk_10MHz(clk_10MHz), .reset(reset), 
                        .lfsr_data(lfsr_out), .bram_write_enable(bram_write_enable), .bram_out(bram_out));

    always #4 clk_125MHz = ~clk_125MHz;
    always #50 clk_10MHz = ~clk_10MHz;

    //counter
    reg [3:0] lfsr_cycle_count = 0;
    always @(posedge clk_10MHz or posedge reset) begin
        if (reset)
            lfsr_cycle_count <= 0;  //reset to 0
        else
            lfsr_cycle_count <= lfsr_cycle_count + 1;   //increment
    end

    integer i;
    initial begin
        clk_125MHz = 0; //start clk low
        clk_10MHz = 0;  // "    "    "
        reset = 1;
        bram_write_enable = 1;

        #50; //50ns
        reset = 0;

        wait (lfsr_cycle_count == 7);    //wait 8 total LFSR cycles
        #50;  //800ns
        $display("Time=%t: BRAM is full", $time);   //print console msg when BRAM is full
        for (i = 0; i < 8; i = i + 1) $display("bram[%d] = %b", i, uut.bram[i]);    //loop through 8 entries

        wait (lfsr_cycle_count == 10);  //wait 11 total LFSR cycles after start, 3 more
        #50;    //50ns
        $display("Time=%t: 3 BRAM values replaced", $time); //print console msg when BRAM is full
        for (i = 0; i < 8; i = i + 1) $display("bram[%d] = %b", i, uut.bram[i]);    //loop through 8 entries

        #850;  //2us
        $finish;
    end

    initial begin
        $monitor("Time=%t, Reset=%b, LFSR=%b, BRAM Out=%b, Cycle Count=%d", 
                 $time, reset, lfsr_out, bram_out, lfsr_cycle_count);
    end
endmodule

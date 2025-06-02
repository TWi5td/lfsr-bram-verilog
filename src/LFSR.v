`timescale 1ns / 1ps

module LFSR(
    input clk,
    input reset,
    output reg [3:0] lfsr_out
    );
    always @(posedge clk or posedge reset) begin
        if (reset)
            lfsr_out <= 4'b1001;    //initial set to 9
        else begin
            lfsr_out[0] <= lfsr_out[3] ^ lfsr_out[1]; //XOR bit 0 of bit 1&3
            lfsr_out[1] <= lfsr_out[0]; //bit0 -> bit1
            lfsr_out[2] <= lfsr_out[1]; //bit1 -> bit2
            lfsr_out[3] <= lfsr_out[2]; //bit2 -> bit3
        end
    end    
endmodule

module bram_interface (
    input clk_125MHz,   //main clk
    input clk_10MHz,    //write pulse clk
    input reset,
    input [3:0] lfsr_data,
    input bram_write_enable,
    output [3:0] bram_out
);
    (* keep = "true" *) reg [3:0] bram [7:0];   //4bit bram
    (* keep = "true" *) reg [2:0] write_addr;   //3bit addr
    reg prev_clk_10MHz;

    wire write_pulse;
    always @(posedge clk_125MHz or posedge reset) begin
        if (reset)
            prev_clk_10MHz <= 0;    //clear old clk state
        else
            prev_clk_10MHz <= clk_10MHz;    //curr clk vlaue
    end
    assign write_pulse = (clk_10MHz && !prev_clk_10MHz) && bram_write_enable;   //on clk rising edge, start write with bram_write_enable

    always @(posedge clk_125MHz or posedge reset) begin
        if (reset) begin
            bram[0] <= 4'b1001;  // Cycle 0 at reset
            write_addr <= 3'b001;  //addr 1, next write
        end else if (write_pulse) begin //rise edge
            bram[write_addr] <= lfsr_data;  //write LFSR to curr addr
            write_addr <= (write_addr + 1) % 8; //wrap arround
        end
    end

    assign bram_out = bram[(write_addr - 1) % 8];   //wrap arround
endmodule

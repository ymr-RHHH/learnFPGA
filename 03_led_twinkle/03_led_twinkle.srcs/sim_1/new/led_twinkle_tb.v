`timescale 1ns / 1ns

module led_twinkle_tb;
    parameter Tclk = 20;

    reg clk;
    reg reset_n;
    wire led;

led_twinkle led_twinkle_inst0(
    .clk(clk),
    .reset_n(reset_n),
    .led(led)
    );


initial clk = 1;
always #(Tclk/2) clk=!clk;

initial begin
    reset_n = 1'b0;
    #(Tclk*200+1);
    reset_n = 1'b1;
    #2_000_000_000;
    $stop;
end

endmodule

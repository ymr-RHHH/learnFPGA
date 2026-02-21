`timescale 1ns / 1ns

module ledRun00_tb;

    parameter Tclk = 20;

    reg clk;
    reg reset_n;
    wire [7:0] led;

ledRun00 ledRun00_inst0(
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
    #2_000_000_000;
    $stop;
end

endmodule

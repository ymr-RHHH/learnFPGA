`timescale 1ns / 1ns


module ledBinking_tb;

parameter Tclk = 20;

reg reset_n;
reg clk;
wire led;


led_linear0 led_linear0_inst(
    .reset_n(reset_n),
    .clk(clk),
    .led(led)
    );

defparam led_linear0_inst.M_clk_cnt = 50_000;   
defparam led_linear0_inst.T_en_led = 12_500;


initial clk = 1;
always #(Tclk/2) clk=!clk;

initial begin
    reset_n = 1'b0;
    #(Tclk*200+1);
    reset_n = 1'b1;
    #2_000_000;
    $stop;
end

endmodule

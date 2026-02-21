`timescale 1ns / 1ns


module led_linear_tb;

parameter Tclk = 20;

reg reset_n;
reg clk;
reg [7:0] data;
wire led;


led_linear3 led_linear3_inst(
    .reset_n(reset_n),
    .clk(clk),
    .led(led),
    .data(data)
);

defparam led_linear3_inst.M_clk_cnt = 12_500;
defparam led_linear3_inst.M_free = 50_000;

initial clk = 1;
always #(Tclk/2) clk=!clk;

initial begin
    reset_n = 1'b0;
    #(Tclk*200+1);
    reset_n = 1'b1;
    data = 8'b1010_1010;
    #1_0000_00;
    data = 8'b1111_1111;
    #20000;
    data = 8'b0010_1000;
    #20000;
    data = 8'b0000_0000;
    #20000;
    data = 8'b0110_1100;
    #20000;
    data = 8'b1010_1010;
    #1_0000_000;
    data = 8'b0101_0101;
    #2_0000_000;
    $stop;
end
endmodule

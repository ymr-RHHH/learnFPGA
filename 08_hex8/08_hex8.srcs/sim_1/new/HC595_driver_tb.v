`timescale 1ns/1ns

module HC595_driver_tb;
    
    reg clk;     
    reg reset_n; 
    reg [7:0]SEL;
    reg [7:0]SEG;
    wire DIO; 
    wire SCLK;
    wire RCLK;

    HC595_Driver HC595_Driver_inst(
    .clk(clk),
    .reset_n(reset_n),
    .SEL(SEL),
    .SEG(SEG),
    .DIO(DIO),
    .SCLK(SCLK),
    .RCLK(RCLK)
    );
    
    initial clk=0;
    always#10 clk = ~clk;
    
    initial begin
    reset_n = 0;
    SEG = 8'b0010_0011;
    SEL = 8'b1100_0101;
    #201;
    reset_n = 1;
    #5000;
    SEG = 8'b0101_0101;
    SEL = 8'b1010_1010;
    #5000;
    SEG = 8'b1111_1111;
    SEL = 8'b1111_1111;
    #5000;
    $stop;
    end    
    
endmodule

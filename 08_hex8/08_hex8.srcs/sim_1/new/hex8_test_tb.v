`timescale 1ns/1ns

module hex8_test_tb;
    
    reg clk;
    reg reset_n;
    reg [31:0]disp_Data;
    wire [7:0]SEL;
    wire [7:0]SEG;

    hex8_test hex8_test_inst (
    .clk(clk),
    .reset_n(reset_n),
    .disp_Data(disp_Data),
    .SEL(SEL),
    .SEG(SEG)
    );
    
    initial clk = 0;
    always#10 clk = ~clk;
    
    initial begin
    reset_n = 0;
    disp_Data=32'h01234567;
    #201
    reset_n = 1;
    #10_000_000;
    disp_Data=32'h89abcdef;
    #10_000_000;
    $stop;
    end

endmodule

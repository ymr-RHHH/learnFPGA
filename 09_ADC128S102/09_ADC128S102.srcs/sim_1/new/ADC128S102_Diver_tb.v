`timescale 1ns / 1ns


module ADC128S102_Diver_tb;

    reg [2:0]Addr;
    wire [11:0]data;
    reg conv_go;
    wire conv_done;
    wire CS_N;
    wire SCLK;
    wire DIN;
    reg DOUT;
    reg clk;
    reg reset_n;

    ADC128S102_Driver ADC128S102_Driver_inst(
    .Addr(Addr),
    .data(data),
    .conv_go(conv_go),      
    .conv_done(conv_done),     
    .CS_N(CS_N),         
    .SCLK(SCLK),
    .DIN(DIN),
    .DOUT(DOUT),
    .clk(clk),
    .reset_n(reset_n)
    );
    
    initial clk = 1;
    always#10 clk = ~clk;
    
    initial begin
        reset_n = 0;
        conv_go = 0;
        Addr =0;
        #201;
        
        reset_n = 1;
        #200;
        
        conv_go = 1;
        Addr = 3;
        #20;
        conv_go = 0;
        wait(!CS_N); // 阻塞语句，当 CS_N == 0 时再接着执行，否则就会卡在这里
        
        @(negedge SCLK); // 关注 SCLK 信号的下降沿， 只有SCLK 信号的下降沿出
                         // 现这句话才会成功执行，然后块中的语句才会向下执行，否则还是会一直卡住
        DOUT = 0; // DB15   // 前四个都是 0
        @(negedge SCLK);
        DOUT = 0; // DB14
        @(negedge SCLK);
        DOUT = 0; // DB13
        @(negedge SCLK);
        DOUT = 0; // DB12
        @(negedge SCLK);
        DOUT = 1; // DB11
        @(negedge SCLK);
        DOUT = 0; // DB10
        @(negedge SCLK);
        DOUT = 1; // DB9
        @(negedge SCLK);
        DOUT = 0; // DB8
        @(negedge SCLK);
        DOUT = 1; // DB7
        @(negedge SCLK);
        DOUT = 0; // DB6
        @(negedge SCLK);
        DOUT = 1; // DB5
        @(negedge SCLK);
        DOUT = 0; // DB4
        @(negedge SCLK);
        DOUT = 1; // DB3
        @(negedge SCLK);
        DOUT = 0; // DB2
        @(negedge SCLK);
        DOUT = 1; // DB1
        @(negedge SCLK);
        DOUT = 0; // DB0
        wait(CS_N);
        #20000;
             
        
        $stop;
    end
    
    
    

endmodule

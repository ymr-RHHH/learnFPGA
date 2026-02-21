// 让led以1Hz的频率闪烁

// 电路板上的晶振的频率是 50 MHz

// 这里使用D触发器加上一个加法器完成的一个计数器来进行计数，从而达到计时的功能
// 由此来完成控制led以 1Hz 的频率闪烁
// CNT_MAX 计数器需要累计的 次数
// Tclk 晶振周期的倒数
// T 计时时长

// CNT_MAX = T / Tclk = 25_000_000

// 由于 $ \lceil log_2 25000000 \rceil = 25 $ 故若位宽低于 25 位就无法表示这个数据 

module led_twinkle(
    clk,
    reset_n,
    led
    );
    parameter CNT_MAX = 25_000_000;
    
    input clk;
    input reset_n;
    output reg led;
    
    reg [24:0] counter;
    
    always@(posedge clk or negedge reset_n) begin
    if(!reset_n)
        // counter<=0; 未指定明确位宽，可能会发生截断
        counter <= 25'd0;
    else if (counter == CNT_MAX -1)
        counter <= 25'd0;
    else
        counter <= counter + 1'd1;
    end
    
    always@(posedge clk or negedge reset_n) begin
    if(!reset_n)
        led <= 1'b0;
    else if (counter == CNT_MAX -1)
        led <= ~led;
    end
    
endmodule

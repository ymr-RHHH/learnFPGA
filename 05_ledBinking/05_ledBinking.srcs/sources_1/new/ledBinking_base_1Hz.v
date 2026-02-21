// LED0以1Hz的频率闪烁，也就是翻转间隔为500ms。
// LED1以2Hz的频率闪烁，也就是翻转间隔为250ms。
// LED2以4Hz的频率闪烁，也就是翻转间隔为125ms。
// LED3以10Hz的频率闪烁，也就是翻转间隔为50ms。

module ledBinking_base_1Hz(
    reset_n,
    clk,
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
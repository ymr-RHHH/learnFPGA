// LED0以1Hz的频率闪烁，也就是翻转间隔为500ms。
// LED1以2Hz的频率闪烁，也就是翻转间隔为250ms。
// LED2以4Hz的频率闪烁，也就是翻转间隔为125ms。
// LED3以10Hz的频率闪烁，也就是翻转间隔为50ms。

module ledBinking(
    reset_n,
    clk,
    led
);

    input clk;
    input reset_n;
    output [3:0] led;
    
    ledBinking_base_1Hz ledBinking_1Hz(
    .reset_n(reset_n),
    .clk(clk),
    .led(led[0])
    );
    
    ledBinking_base_1Hz
    #(
        .CNT_MAX(12_500_000)
    )
    ledBinking_2Hz
    (
    .reset_n(reset_n),
    .clk(clk),
    .led(led[1])
    );
    
    ledBinking_base_1Hz
    #(
        .CNT_MAX(6_250_000)
    )
    ledBinking_4Hz
    (
    .reset_n(reset_n),
    .clk(clk),
    .led(led[2])
    );
    
    ledBinking_base_1Hz
    #(
        .CNT_MAX(2_500_000)
    )
    ledBinking_10Hz
    (
    .reset_n(reset_n),
    .clk(clk),
    .led(led[3])
    );

endmodule
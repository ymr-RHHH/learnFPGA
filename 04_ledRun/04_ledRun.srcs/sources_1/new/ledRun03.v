// 实现LED流水灯（每0.5s换个灯）
// 38译码器法

module ledRun03(
    clk,
    reset_n,
    led
    );
    parameter CNT_MAX = 25_000;
    
    input clk;
    input reset_n;
    output [7:0] led;
    
    reg [24:0] counter;
    reg [2:0] counter_38;
    
    decoder3_8 decoder3_8_inst01(
        .in(counter_38),
        .out(led)
    );
    
    always@(posedge clk or negedge reset_n) begin
    if(!reset_n)
        counter <= 25'd0;
    else if (counter == CNT_MAX -1)
        counter <= 25'd0;
    else
        counter <= counter + 1'd1;
    end
    
    always@(posedge clk or negedge reset_n) begin
    if(!reset_n)
        counter_38 <= 3'd0;
    else if (counter == CNT_MAX -1)
        // counter_38 <= (counter_38 +1)%8;
        // 不建议使用取模运算，可能会综合出很发杂的逻辑电路，尽管结果是正确的
        counter_38 <= counter_38 + 1'd1;
    end
 
endmodule

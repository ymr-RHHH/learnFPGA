// 实现LED流水灯（每0.5s换个灯）
// 位移法
module ledRun01(
    clk,
    reset_n,
    led
    );
    parameter CNT_MAX = 25_000_000;
    
    input clk;
    input reset_n;
    output reg [7:0] led;
    
    reg [24:0] counter;
    
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
        led <= 8'b0000_0000;
    else if (counter == CNT_MAX -1)begin
        if(led == 8'b1000_0000 | led == 8'b0000_0000) 
            led <= 8'b0000_0001;
        else
            led <= led << 1'b1;
        end
    end
 
endmodule

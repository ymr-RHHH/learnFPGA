 // 线性序列机的原理与应用 01
// led 亮0.25s ，灭 0.75s

module led_linear0(
    reset_n,
    clk,
    led
    );
    
     input reset_n;
     input clk;
     output reg led;
     
     reg [25:0] clk_cnt;
     parameter M_clk_cnt = 50_000_000;
     parameter T_led     = 12_500_000;
     // 计数器模块
     always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            clk_cnt <= 0;
        else begin
            if(clk_cnt == M_clk_cnt - 1)
                clk_cnt <= 0;
            else
                clk_cnt <= clk_cnt + 1'd1;
        end
     end
     
     // led模块
     always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            led <= 0;
        else if(clk_cnt == 0)
            led <= 1'd1;
        else if(clk_cnt == T_led)
            led <= 0;
     end

endmodule

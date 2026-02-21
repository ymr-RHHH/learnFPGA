// 让LED以亮0.25秒->灭0.5秒->亮0.75秒->灭1秒的规律，持续循环闪烁

// 注意到 0.5  0.75  1 都是 0.25 的整数倍
// 所以就可以使用case语句来写

module led_linear1(
    reset_n,
    clk,
    led
    );
    
     input reset_n;
     input clk;
     output reg led;
     
     reg [23:0] clk_cnt;
     parameter M_clk_cnt = 12_500_000;
          
     // 计时器模块
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
     
     // 计数器模块
     reg [4:0] cnt;
     always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            cnt <= 0;
        else begin
            if(clk_cnt == M_clk_cnt - 1)begin
                if(cnt == 9)
                    cnt <= 0;
                else
                    cnt <= cnt+1;
            end
        end
     end
     
    // led模块
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            led <= 0;
        else begin
            case(cnt)
            0:  led <= 1'd1;
            1:  led <= 1'd0;
            2:  led <= 1'd0;
            3:  led <= 1'd1;
            4:  led <= 1'd1;
            5:  led <= 1'd1;
            6:  led <= 1'd0;
            7:  led <= 1'd0;
            8:  led <= 1'd0;
            9:  led <= 1'd0;
            default: led <= led;
            endcase
        end
    end
    
endmodule

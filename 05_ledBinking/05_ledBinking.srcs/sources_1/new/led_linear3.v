// 在led_linear2 的基础上，实现每个一定时间，比如一秒钟，执行一次 led 8个状态的切换控制 

module led_linear3(
    reset_n,
    clk,
    led,
    data
    );
    
     input reset_n;
     input clk;
     output reg led;
     
     input [7:0] data;
     
     reg en_led;
     reg [23:0] clk_cnt;
     parameter M_clk_cnt = 12_500_000;
          
     // 计时器模块 0.25s
     always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            clk_cnt <= 0;
        else begin
            if(en_led)begin
                if(clk_cnt == M_clk_cnt - 1)
                    clk_cnt <= 0;
                else
                    clk_cnt <= clk_cnt + 1'd1;
            end
        end
     end
     
     // led状态控制模块
     reg [2:0] cnt;
     always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            cnt <= 0;
        else begin
            if(clk_cnt == M_clk_cnt - 1)begin
                if(cnt == 7)
                    cnt <= 0;
                else
                    cnt <= cnt+1'd1;
            end
        end
     end
     
     // 空闲状态计数器
     parameter M_free = 50_000_000;
     reg [25:0] cnt_free;
     always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            cnt_free <= 0;
        else begin 
            if(!en_led)begin
                if(cnt_free == M_free - 1)
                    cnt_free <= 0;
                else
                    cnt_free <= cnt_free + 1'd1;
            end
        end
     end
     
     //  状态控制模块（切换空闲和闪烁态）
     always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            en_led = 0;
        else if(cnt_free == M_free - 1)
            en_led = 1;
        else if((cnt == 7)&&(clk_cnt == M_clk_cnt - 1))
            en_led = 0;
     end
     
     // 数据存储模块（仅在空闲态存贮数据）
     reg [7:0] r_data;
     always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            r_data <= 0;
        else if(!en_led)
            r_data <= data;
     end
     
    // led模块
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            led <= 0;
        else begin
            case(cnt)
            0:  led <= r_data[0];
            1:  led <= r_data[1];
            2:  led <= r_data[2];
            3:  led <= r_data[3];
            4:  led <= r_data[4];
            5:  led <= r_data[5];
            6:  led <= r_data[6];
            7:  led <= r_data[7];
            default: led <= led;
            endcase
        end
    end
    
endmodule

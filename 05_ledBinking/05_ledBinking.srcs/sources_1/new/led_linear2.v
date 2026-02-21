// 以0.25秒为基本的LED状态变化间隔（最小时间单元)
// 以8个小段为一个循环周期(参考任务2的10个小段)
// LED在每一小段该点亮还是熄灭，由一个8位的输入端口指定

module led_linear2(    
    reset_n,
    clk,
    led,
    data
    );
    
     input reset_n;
     input clk;
     output reg led;
     
     input [7:0] data;
     
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
     
     
    // led模块
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            led <= 0;
        else begin
            case(cnt)
            0:  led <= data[0];
            1:  led <= data[1];
            2:  led <= data[2];
            3:  led <= data[3];
            4:  led <= data[4];
            5:  led <= data[5];
            6:  led <= data[6];
            7:  led <= data[7];
            default: led <= led;
            endcase
        end
    end
    
endmodule

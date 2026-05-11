module key_filter(
    clk,
    reset_n,
    key,
    key_P_Flag,
    key_R_Flag,
    key_state  // 输出滤波后的波形
    );
    
    input clk;
    input reset_n;
    input key;
    output reg key_P_Flag;
    output reg key_R_Flag;
    output reg key_state;
    
    // 计数器
    parameter MCNT_20ms = 1000_000 - 1;
    reg [19:0] cnt;
    
// 计数器逻辑写在状态机外部，会导致
//  else if ((state == P_FILTER) || (state == R_FILTER))
// 在判断状态时和状态机的状态不同步，这里的状态会晚于状态机一个时钟周期
// 所以应该把计数器逻辑写在状态机内部，以保证状态的同步
//    always@(posedge clk or negedge reset_n)begin
//        if(!reset_n)
//            cnt <= 0;
//        else if ((state == P_FILTER) || (state == R_FILTER))
//            cnt <= cnt + 1'd1;
//        else
//            cnt <= 0;
//    end
    
    wire time_20ms_reached;
    assign time_20ms_reached = (cnt >= MCNT_20ms);
        
    // 两个D触发器级联，用于同步异步信号，防止出现亚稳态
    reg sync_d0_Key;
    reg sync_d1_Key;
    reg r_Key;
    
    // 上升沿和下降沿检测
    wire pedge_Key;
    wire nedge_Key;
    
    always@(posedge clk)
        sync_d0_Key <= key;
        
    always@(posedge clk)
        sync_d1_Key <= sync_d0_Key;
    
    always@(posedge clk)
        r_Key <= sync_d1_Key;
    
    assign nedge_Key = (sync_d1_Key == 0) && (r_Key == 1);
    assign pedge_Key = (sync_d1_Key == 1) && (r_Key == 0);
    
     // 为了方便后面阅读程序的时候快速理解每个数字代表的状态，往往会直接用状态名代替数字
     // 由于状态机的状态并不需要像之前那样被例化后进行参数值的修改，并且要是被修改了可能会
     // 产生未知的错误，这个时候就需要用 localparam 关键字了
     localparam IDLE = 0;  // 也不知道为啥 localparam 没高亮，但是这个确实是对的
     localparam P_FILTER = 1;
     localparam WAIT_R = 2;
     localparam R_FILTER = 3;
     
     reg [1:0] state;
     
     always@(posedge clk or negedge reset_n)begin
        if(!reset_n)begin
            state <= IDLE;
            key_R_Flag <= 1'd0;
            key_P_Flag <= 1'd0;
            cnt <= 1'd0;
            key_state <= 1'd0;
        end 
        else begin
            case(state)
                IDLE:
                    begin
                        key_R_Flag <= 1'd0;
                        if(nedge_Key)
                            state <= P_FILTER;
                    end
                P_FILTER:
                    begin
                        if(time_20ms_reached)begin
                            state <= WAIT_R;
                            key_P_Flag <= 1'd1;
                            cnt <= 1'd0;
                            key_state <= 1'd0;
                            end
                        else if(pedge_Key)begin
                            state <= IDLE;
                            cnt <= 1'd0;
                            end
                        else begin
                            state <= state;
                            cnt <= cnt + 1;
                        end
                    end
                WAIT_R:
                    begin
                        key_P_Flag <= 1'd0;
                        if(pedge_Key)
                            state <= R_FILTER;
                    end
                R_FILTER:
                    begin
                        if(time_20ms_reached)begin
                            state <= IDLE;
                            key_R_Flag <= 1'd1;
                            cnt <= 1'd0;
                            key_state <= 1'd1;
                            end
                        else if(nedge_Key)begin
                            state <= WAIT_R;
                            cnt <= 1'd0;
                            end
                        else begin
                            state <= state;
                            cnt <= cnt + 1;
                        end
                    end
            endcase
        end
     end
    
    
     
endmodule

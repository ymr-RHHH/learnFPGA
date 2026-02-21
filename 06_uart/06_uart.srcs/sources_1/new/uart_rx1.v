// 之前写的uart_rx 虽然能过仿真，但是还有很多问题，比如边沿检测啥都没做
// （实际上是没听课就直接一顿操作了，什么毛刺信号的处理啥的都没考虑。。。。。。。）
// 代码重写一遍吧。。。。。。。

module uart_rx1(
    clk,
    reset_n,
    uart_tx,
    rx_data,
    rx_done
    );
    
    input clk;
    input reset_n;
    input uart_tx;
    output reg [7:0] rx_data;
    output reg rx_done;
    
    parameter CLK_FREQ = 50_000_000;
    parameter BAUD_9600 = 9600;
    parameter BAUD_14400 = 14400;
    parameter BAUD_56000 = 56000;
    parameter BAUD_115200 = 115200;
    
    parameter M_Baud_cnt = CLK_FREQ / BAUD_115200 - 1;

    reg en_send_rx; // 为高电平时启动发送
    // 波特率计数器逻辑
    reg [31:0] baud_div_cnt;
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n || (!en_send_rx))
            baud_div_cnt <= 1'd0;
        else if(en_send_rx)begin
            if(baud_div_cnt == M_Baud_cnt)
                baud_div_cnt <= 1'd0;
            else
                baud_div_cnt <= baud_div_cnt + 1'd1;
        end
    end
    
    // 位计数器
    reg [3:0] bit_cnt;
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n || (!en_send_rx))
            bit_cnt <= 0;
        else if(baud_div_cnt == M_Baud_cnt)begin
            if(bit_cnt == 9)
                bit_cnt <= 0;
            else
                bit_cnt <= bit_cnt + 1'd1;
        end
    end
    
    // 接受完成标志信号
    wire MG_rx_done;
    assign MG_rx_done = (bit_cnt == 9) && (baud_div_cnt == M_Baud_cnt);
    
    // UART 信号边沿检测逻辑
    reg r_uart_tx;
    wire uart_tx_neg;
    always@(posedge clk)
        r_uart_tx <= uart_tx;
    
    assign uart_tx_neg = (uart_tx == 0) && (r_uart_tx == 1);
    
    
    // 波特率计数器使能逻辑
    always@(posedge clk or negedge reset_n or negedge uart_tx)begin 
        if(!reset_n)                                                
            en_send_rx <= 0;                                        
        else if((baud_div_cnt == 0)&&(bit_cnt == 0)&&(uart_tx_neg))
            en_send_rx <= 1;
        //处理毛刺信号
        else if((baud_div_cnt == M_Baud_cnt/2) && (bit_cnt == 0) && (uart_tx == 1))
            en_send_rx <= 0;
        else if(MG_rx_done)
            en_send_rx <= 0;
    end
    

    // 位接受逻辑
    reg [7:0] r_rx_data;
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            r_rx_data <= 0;
        else if(en_send_rx) begin
            if(baud_div_cnt == M_Baud_cnt /2)
            begin
                case(bit_cnt)
                    1:r_rx_data[0] <= uart_tx;
                    2:r_rx_data[1] <= uart_tx;
                    3:r_rx_data[2] <= uart_tx;
                    4:r_rx_data[3] <= uart_tx;
                    5:r_rx_data[4] <= uart_tx;
                    6:r_rx_data[5] <= uart_tx;
                    7:r_rx_data[6] <= uart_tx;
                    8:r_rx_data[7] <= uart_tx;
                    default: r_rx_data <= r_rx_data;
                endcase
            end
        end
    end
    
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            rx_data <= 0;
        else if(MG_rx_done)
            rx_data <= r_rx_data;
    end
    

    // led翻转逻辑
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            rx_done <= 0;
        else if(MG_rx_done)  
            rx_done <= ~rx_done;      
    end
endmodule

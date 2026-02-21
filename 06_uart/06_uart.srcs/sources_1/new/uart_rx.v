// 设计一个UART串口接收逻辑控制器,要求:
// 能够接收8位，无校验位，1位停止位的UART串口数据
// 能够通过一定的方式修改波特率(parameter)
// 每接收完一个数据,将接收到的数据结果显示到EDA扩展板的8位LED灯上
// 每接收完一个数据，将开发板上本身的PL_LED状态翻转一次(注意是翻转,不是闪烁,效果同串口发送逻辑的一样)

module uart_rx(
    clk,
    reset_n,
    uart_tx,
    rx_data,
    //rx_done
    );
    
    input clk;
    input reset_n;
    input uart_tx;
    output reg [7:0] rx_data;
    //output reg rx_done;
    
    parameter CLK_FREQ = 50_000_000;
    parameter BAUD_9600 = 9600;
    parameter BAUD_14400 = 14400;
    parameter BAUD_56000 = 56000;
    parameter BAUD_115200 = 115200;
    
    parameter M_Baud_cnt = CLK_FREQ / BAUD_115200 - 1;
    
    reg en_send_rx;
    // 波特率时钟模块
    reg [12:0] Baud_clk;
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n || (!en_send_rx))
            Baud_clk <= 0;
        else if(en_send_rx) begin
            if(Baud_clk == M_Baud_cnt)
                Baud_clk <= 0;
            else
                Baud_clk <= Baud_clk + 1'd1;
        end
    end
    
    // 波特率计数模块    
    reg [3:0] Baud_cnt;
    always@(posedge clk or negedge reset_n)begin
        if((!reset_n) || (!en_send_rx))
            Baud_cnt <= 0;
        else if(Baud_clk == M_Baud_cnt)begin
            if(Baud_cnt == 9)
                Baud_cnt <= 0;
            else
                Baud_cnt <= Baud_cnt + 1'd1;
        end
    end
    
    // 接受完成提示
    wire MG_rx_done;
    assign MG_rx_done = (Baud_cnt == 9) && (Baud_clk == M_Baud_cnt);
    
    // rx使能信号控制
    always@(posedge clk or negedge reset_n or negedge uart_tx)begin // 使用了非时钟信号uart_tx，逻辑上没问题
        if(!reset_n)                                                // 但是现实中会让D触发器的时钟信号的质量
            en_send_rx <= 0;                                        // 变得很差，应该写单独的上下边沿检测电路
        else if((Baud_clk == 0)&&(Baud_cnt == 0)&&(uart_tx == 0))
            en_send_rx <= 1;
        else if(MG_rx_done)
            en_send_rx <= 0;
    end
    
    // 数据接受存储逻辑
    reg [7:0] r_rx_data;
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            r_rx_data <= 0;
        else if(en_send_rx) begin
            if((Baud_cnt == 1) && (Baud_clk == M_Baud_cnt / 2))
                r_rx_data[0] <= uart_tx;
            else if((Baud_cnt == 2) && (Baud_clk == M_Baud_cnt / 2))
                r_rx_data[1] <= uart_tx;
            else if((Baud_cnt == 3) && (Baud_clk == M_Baud_cnt / 2))
                r_rx_data[2] <= uart_tx;
            else if((Baud_cnt == 4) && (Baud_clk == M_Baud_cnt / 2))
                r_rx_data[3] <= uart_tx;
            else if((Baud_cnt == 5) && (Baud_clk == M_Baud_cnt / 2))
                r_rx_data[4] <= uart_tx;
            else if((Baud_cnt == 6) && (Baud_clk == M_Baud_cnt / 2))
                r_rx_data[5] <= uart_tx;
            else if((Baud_cnt == 7) && (Baud_clk == M_Baud_cnt / 2))
                r_rx_data[6] <= uart_tx;
            else if((Baud_cnt == 8) && (Baud_clk == M_Baud_cnt / 2))
                r_rx_data[7] <= uart_tx;
        end
    end
    
    // 数据接受逻辑
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            rx_data <= 0;
        // if(MG_rx_done)  // 不能这么写，会导致报错[Synth 8-91] ambiguous clock in event control
        //    rx_data <= r_rx_data;  
        // 产生这个错误的原因主要有两种情况。
        // 第一种情况:
        //  是在always块中，我们习惯将时钟上升沿和复位下降沿写在一起，但如果在always块中没有初始化的变量，即我们并没有使用到复位信号（如rst_n），综合时就会报错。
        //  解决方法:
        //    将触发模式更改为仅在时钟上升沿触发，即使用always @ (posedge clk)。
        // 第二种情况：
        // 赋值冲突。在同一个always块中，如果两个if语句处理的内容有交集，即对同一个变量进行了赋值，就会产生赋值冲突。硬件电路无法确定先处理哪个if的操作，也无法构建硬件电路，综合也会失败。
        else if(MG_rx_done)
            rx_data <= r_rx_data;
    end
    
    // led翻转逻辑
//    always@(posedge clk or negedge reset_n)begin
//        if(!reset_n)
//            rx_done <= 0;
//        else if(MG_rx_done)
//            rx_done <= ~rx_done;
//    end
endmodule

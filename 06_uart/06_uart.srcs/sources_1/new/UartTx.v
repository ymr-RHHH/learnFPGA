// 之前写的uart_tx 只能隔一秒钟发送一次数据。
// 但是在实际应用中指定不是一秒钟发一次，而是由接受设备给出信号开始发送，时间是随机的
// 也就是说，uart_tx 的端口并不规范

// 除此以外，还有无法调整波特率的问题，实际上为了匹配多种设备，波特率不可能只有9600

// 按理来讲，应该还要能做到调整传输位数，这个问题暂时先忽略，就8位

module UartTx(
    clk,
    reset_n,
    data,
    en_send_tx,
    select_baud,
    uart_tx,
    tx_done
    );
    input clk;
    input reset_n;
    input [7:0] data;
    input en_send_tx;
    input [1:0] select_baud;
    output reg uart_tx;
    output tx_done;
    
    parameter CLK_FREQ = 50_000_000;
    parameter BAUD_9600 = 9600;
    parameter BAUD_14400 = 14400;
    parameter BAUD_56000 = 56000;
    parameter BAUD_115200 = 115200;
    
    // 波特率选择数据模块（确保仅在上电或复位时可以选择）
    reg [12:0] M_Baud_cnt;
    always@(negedge reset_n)begin
        if(!reset_n)begin
            case(select_baud)
                0: M_Baud_cnt = CLK_FREQ / BAUD_9600 - 1;
                1: M_Baud_cnt = CLK_FREQ / BAUD_14400 - 1; 
                2: M_Baud_cnt = CLK_FREQ / BAUD_56000 - 1;
                3: M_Baud_cnt = CLK_FREQ / BAUD_115200 - 1;
                default: M_Baud_cnt = CLK_FREQ / BAUD_9600 - 1;
            endcase
        end
    end
    

    // 波特率时钟模块
    reg [12:0] Baud_clk;
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            Baud_clk <= 0;
        else if(en_send_tx) begin
            if(Baud_clk == M_Baud_cnt)
                Baud_clk <= 0;
            else
                Baud_clk <= Baud_clk + 1'd1;
        end
    end
    
    // 波特率计数模块    
    reg [3:0] Baud_cnt;
    always@(posedge clk or negedge reset_n or negedge en_send_tx)begin
        if((!reset_n) || (!en_send_tx))
            Baud_cnt <= 0;
        else if(Baud_clk == M_Baud_cnt)begin
            if(Baud_cnt == 9)
                Baud_cnt <= 0;
            else
                Baud_cnt <= Baud_cnt + 1'd1;
        end
    end
    
    // 发送完成提示
    assign tx_done = (Baud_cnt == 9) && (Baud_clk == M_Baud_cnt);
    
    // 状态控制逻辑
    reg tx_busy;
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            tx_busy <= 0;
        else if(en_send_tx)begin
            if((Baud_cnt == 0) && (Baud_clk == 0))
                tx_busy <= 1'd1;
            else if(tx_done)
                tx_busy <= 0;
        end
    end
    // 数据锁存逻辑（确保发送数据时，该周期内数据不变）
    reg [7:0] r_data;
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            r_data <= 0;
        else if(en_send_tx && !tx_busy)
            r_data <= data;
        else
            r_data <= r_data;
    end
    
    // 发送模块
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            uart_tx <= 1'd1;
        else if(en_send_tx)begin
            case(Baud_cnt)
            0:  uart_tx <= 1'd0;
            1:  uart_tx <= r_data[0];
            2:  uart_tx <= r_data[1];
            3:  uart_tx <= r_data[2];
            4:  uart_tx <= r_data[3];
            5:  uart_tx <= r_data[4];
            6:  uart_tx <= r_data[5];
            7:  uart_tx <= r_data[6];
            8:  uart_tx <= r_data[7];
            9:  uart_tx <= 1'd1;
            default: uart_tx <= 1'd1;
            endcase
        end
        else
            uart_tx <= 1'd1;
    end
    
endmodule

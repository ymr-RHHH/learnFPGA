// 设计一个串口发送模块，发送用户输入的数据给电脑，要求：
//     波特率为9600
//     8位数据位
//     1位停止位
//     无校验位
//     无流控功能
//     每1s后发送一次当前8位拨码开关的值每次发送完成后将LEDO的状态翻转

module uart_tx(
    uart_tx,
    led,
    data,
    clk,
    reset_n
);
    output reg uart_tx;
    output reg led;
    input [7:0] data;
    input clk;
    input reset_n;
    
    // 波特率生成计数器
    parameter M_generate_baud = 5208;
    reg [12:0] generate_baud_cnt;
    reg en_uart_tx;
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            generate_baud_cnt <= 0;
        else if(en_uart_tx) begin
            if(generate_baud_cnt == M_generate_baud -1)
                generate_baud_cnt <= 0;
            else
                generate_baud_cnt <= generate_baud_cnt + 1'd1;
        end            
    end
    
    // 波特率控制计数器
    reg [3:0] baud_crl;
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            baud_crl <= 0;
        else if(generate_baud_cnt == M_generate_baud -1) begin
            if(baud_crl == 9)
                baud_crl <= 0;
            else
                baud_crl <= baud_crl + 1'd1;
        end            
    end
    
    // 延时计数器
    parameter M_delay_cnt = 50_000_000;
    reg [25:0] delay_cnt;
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            delay_cnt <= 0;
        else if(!en_uart_tx)begin
            if(delay_cnt == M_delay_cnt)
                delay_cnt <= 0;
            else
                delay_cnt <= delay_cnt + 1'd1;
        end
    end
    
    // 延时发送控制逻辑
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            en_uart_tx <= 0;
        else if(delay_cnt == M_delay_cnt)
            en_uart_tx <= 1'd1;
        else if((generate_baud_cnt == M_generate_baud -1) && baud_crl == 9)
            en_uart_tx <= 0;
    end
 
    // 数据存储逻辑（确保发送数据时数据不变）
    reg [7:0] r_data;
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            r_data <= 0;
        else if(en_uart_tx == 0)
            r_data <= data;
    end
    
    // 数据发送模块
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            uart_tx <= 1'd1;
        else if(en_uart_tx)begin
            case(baud_crl)
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
            default: uart_tx <= uart_tx;
            endcase
        end
        else
            uart_tx <= 1'd1;
    end
    
    // led翻转逻辑
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            led <= 0;
        else if((generate_baud_cnt == M_generate_baud -1) && baud_crl == 9)
            led <= ~led;
    end
 
endmodule
`timescale 1ns / 1ns

module uart_tx_tb;

    wire uart_tx;
    wire tx_done;
    reg [7:0] data;
    reg clk;
    reg reset_n;
    reg en_send_tx;
    reg [1:0] select_baud;

    UartTx UartTx_inst0(
        .clk(clk),
        .reset_n(reset_n),
        .data(data),
        .en_send_tx(en_send_tx),
        .select_baud(select_baud),
        .uart_tx(uart_tx),
        .tx_done(tx_done)
    );
    
    

    initial clk = 1;
    always #10 clk = ~clk;
    
    initial begin
        reset_n = 0;
        select_baud = 3;
        #201;
        reset_n = 1;   
            
        en_send_tx = 1;
        
        data = 8'b1010_1010;
        #5000_000
        data = 8'b0101_0101;
        #6000_000
        
        $stop;
    end

endmodule

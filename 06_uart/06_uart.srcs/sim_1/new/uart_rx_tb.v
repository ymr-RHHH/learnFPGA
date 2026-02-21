`timescale 1ns / 1ns

module uart_rx_tb;

reg clk;
reg reset_n;
reg uart_tx;

wire [7:0] rx_data;
wire rx_done;

uart_rx1 uart_rx_inst0(
    .clk(clk),
    .reset_n(reset_n),
    .uart_tx(uart_tx),
    .rx_data(rx_data),
    .rx_done(rx_done)
    );

initial clk = 1;
always#10 clk = ~clk;

initial begin
    reset_n = 0;uart_tx=1;
    #201;
    reset_n = 1;
    #201;
    
    // 8'b1010_1010
    uart_tx=0;#(434*20); // 起始位
    uart_tx=0;#(434*20); // bit0
    uart_tx=1;#(434*20); // bit1
    uart_tx=0;#(434*20); // bit2
    uart_tx=1;#(434*20); // bit3
    uart_tx=0;#(434*20); // bit4
    uart_tx=1;#(434*20); // bit5
    uart_tx=0;#(434*20); // bit6
    uart_tx=1;#(434*20); // bit7
    uart_tx=1;#(434*20); // 结束位
    
  
    // 8'b1100_1100
    uart_tx=0;#(434*20); // 起始位
    uart_tx=0;#(434*20); // bit0
    uart_tx=0;#(434*20); // bit1
    uart_tx=1;#(434*20); // bit2
    uart_tx=1;#(434*20); // bit3
    uart_tx=0;#(434*20); // bit4
    uart_tx=0;#(434*20); // bit5
    uart_tx=1;#(434*20); // bit6
    uart_tx=1;#(434*20); // bit7
    uart_tx=1;#(434*20); // 结束位
    
    #4000;
    $stop;
end

endmodule

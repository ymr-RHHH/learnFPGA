// 实现LED流水灯（每0.5s换个灯）
// 位拼接法(循环位移)

// 这种方法在实际案例里也难以用到，只要是为了学Verilog语法

module ledRun02(
    clk,
    reset_n,
    led
    );
    parameter CNT_MAX = 25_000;
    
    input clk;
    input reset_n;
    output reg [7:0] led;
    
    reg [24:0] counter;
    
    always@(posedge clk or negedge reset_n) begin
    if(!reset_n)
        counter <= 25'd0;
    else if (counter == CNT_MAX -1)
        counter <= 25'd0;
    else
        counter <= counter + 1'd1;
    end
    
    always@(posedge clk or negedge reset_n) begin
    if(!reset_n)
        led <= 8'b0000_0001;
    else if (counter == CNT_MAX -1)
        led <= {led[6:0],led[7]};
        // led <= {led[6:0],NewData[7]} // newdata 代码相同的信号
    end
 
endmodule

// 测试always语句合并模块会怎样
// 测试证明，你合并了也没鸡毛关系，仿真跑出来都是一模一样的，板级验证也是一样的
// 小梅哥说：‘合并了可能会导致编译错误’。我觉得可能是针对一些仅支持老版本的verilog标准而言的
// 但是最好还是应该分开写，因为我们写代码就要高内聚低耦合，且模块化的代码更利于调试和维护
// 总结：
//  分开写的好处：
//  1.模块化：每个 always 块负责一个功能
//  2.易维护：修改计数器不影响LED逻辑
//  3.易调试：可以单独监控计数器或LED
//  4.符合编码规范：大多数公司规范推荐功能分离

// 实际上，只有当两个信号逻辑紧密耦合，且行为必须完全同步时才考虑合并。
// 但是在现实中往往不合并。


module ledRun00(
    clk,
    reset_n,
    led
    );
    parameter CNT_MAX = 25_000_000;
    
    input clk;
    input reset_n;
    output reg [7:0] led;
    
    reg [24:0] counter;
    
    always@(posedge clk or negedge reset_n) begin
    if(!reset_n)begin
        counter <= 25'd0;
        led <= 8'b0000_0001;
        end
    else if (counter == CNT_MAX -1)begin
        counter <= 25'd0;
            begin
            if(led == 8'b1000_0000 | led == 8'b0000_0000) 
                led <= 8'b0000_0001;
            else
                led <= led << 1'b1;
            end
        end
    else
        counter <= counter + 1'd1;
    end
     
endmodule

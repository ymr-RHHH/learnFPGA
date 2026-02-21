// 用于仿真的第一行代码，永远都是timescale
`timescale 1ns/1ns  // 指定代码仿真的时候的延时语句的 单位/精度（即延时的最小单位）

module mux2_tb;  // test branch 文件不需要端口列表

// 定义信号 
// 使用reg来定义随时要修改的信号
reg S0,S1,S2;
// 放根导线就能检测输出信号
wire mux2_out;

// 例化模块 mux2 , 并连接信号
mux2 mux2_inst0(
    .a(S0),
    .b(S1),
    .sel(S2),
    .out(mux2_out)
);

// 产生输入信号
initial begin  // 仿真信号从此开始，逐句执行
        S2 = 0; S1 = 0; S0 = 0;  //sel = S2 = 0；mux2_out = out = a= S0 = 0；
        #20;
        S2 = 0; S1 = 0; S0 = 1;  //sel = S2 = 0；mux2_out = out = a= S0 = 1；
        #20;        
        S2 = 0; S1 = 1; S0 = 0;  //sel = S2 = 0；mux2_out = out = a= S0 = 0；
        #20;
        S2 = 0; S1 = 1; S0 = 1;  //sel = S2 = 0；mux2_out = out = a= S0 = 1；
        #20;      
        S2 = 1; S1 = 0; S0 = 0;  //sel = S2 = 1；mux2_out = out = b= S1 = 0；
        #20;
        S2 = 1; S1 = 0; S0 = 1;  //sel = S2 = 1；mux2_out = out = b= S1 = 0；
        #20;        
        S2 = 1; S1 = 1; S0 = 0;  //sel = S2 = 1；mux2_out = out = b= S1 = 1；
        #20;
        S2 = 1; S1 = 1; S0 = 1;  //sel = S2 = 1；mux2_out = out = b= S1 = 1；
        #20;  
        $stop;
end  // 信号输入结束

endmodule
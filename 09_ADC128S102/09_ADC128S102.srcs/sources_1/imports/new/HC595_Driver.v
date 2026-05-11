// 由于直接使用 hex8_text 中提供的来驱动数码管的话，会大量的占用FPGA的管脚资源
// 而在EDA扩展板上使用的是 HC595 串转并芯片来间接驱动数码管的
// 所以这里还得给 HC595 写个驱动，然后把 hex8_text 模块连接这个驱动才能进行板级验证

module HC595_Driver(
    clk,
    reset_n,
    SEL,
    SEG,
    DIO,
    SCLK,
    RCLK
    );
    
    input clk;
    input reset_n;
    input [7:0]SEL;
    input [7:0]SEG;
    output reg DIO;
    output reg SCLK;
    output reg RCLK;
    
    // 先解决 SCLK 模块
    // SCLK 模块就是负责给 HC595 一个时钟，用来读取串行数据的
    // 查 HC595 芯片的数据手册，并没有给出对于 LVCOM33 电平标准的一个频率上限，
    // 那就取下限 5 MHz
    // 5 MHz 即 每 100 ns 将当前信号取反， 即 FPGA的50MHz 的 clk 每来 5次上升沿
    // 就翻转一次
    
    // FPGA 的时钟是 50MHz
    // 正常来讲是要考虑极限情况，比如换个环境的话可能接的就是 1GHz 的高速晶振了，
    // 这个时候就要适当的增加计数器的位宽
    
    // 查数据手册知：只要在 SCLK 上升沿之前 100 ns 稳定信号（这是一个上限）就铁定不会有任何问题
    // 还有就是 RCLK 的上升沿和 SCLK 的上升沿不能同时出现（可以选择在下降沿出现）
    
    // 这里使用线性序列机来完成
    
    // 分频计数器
    reg [2:0] cnt_div_5MHz;
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)begin
            cnt_div_5MHz <= 0;
            end
        else if(cnt_div_5MHz == 4)begin
            cnt_div_5MHz <= 0;
            end
        else
            cnt_div_5MHz <= cnt_div_5MHz + 1'd1;
    end
    
    // 节拍计数器
    // 共传输 16 位数据，一个数据占 半个 SCLK， 共计 32 拍
    reg [4:0] cnt;
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            cnt <= 0;
        else if(cnt_div_5MHz == 4)
            cnt <= cnt + 1'd1;
    end     
    
    // 线性序列机
    // md，第一版代码我还在想能不能直接使用计数器+信号翻转，然后把SCLK当成敏感信号，然后再对DIO赋值，
    // 想破脑袋没想到用的是线性序列机。。。。。。关键是还这么简单。。。。。。
    // 这32个状态你就写吧。。。。。。不过确实是最简单的不用动脑子的最好调试的。。。。。。
    // 还是得相信经验这东西。。。。。。
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)begin
            DIO <= 1'd0;
            SCLK <= 1'd0;
            RCLK <= 1'd0;
        end
        else begin
            case(cnt)
                0:begin DIO <= SEG[7]; SCLK <= 1'd0; RCLK <= 1'd1; end
                1:begin SCLK <= 1'd1; RCLK <= 1'd0; end
                
                2:begin DIO <= SEG[6]; SCLK <= 1'd0; end
                3:begin SCLK <= 1'd1; end
                
                4:begin DIO <= SEG[5]; SCLK <= 1'd0; end
                5:begin SCLK <= 1'd1; end
                
                6:begin DIO <= SEG[4]; SCLK <= 1'd0; end
                7:begin SCLK <= 1'd1; end
                
                8:begin DIO <= SEG[3]; SCLK <= 1'd0; end
                9:begin SCLK <= 1'd1; end
                
                10:begin DIO <= SEG[2]; SCLK <= 1'd0; end
                11:begin SCLK <= 1'd1; end
                
                12:begin DIO <= SEG[1]; SCLK <= 1'd0; end
                13:begin SCLK <= 1'd1; end
                
                14:begin DIO <= SEG[0]; SCLK <= 1'd0; end
                15:begin SCLK <= 1'd1; end
                
                16:begin DIO <= SEL[7]; SCLK <= 1'd0; end
                17:begin SCLK <= 1'd1; end
                
                18:begin DIO <= SEL[6]; SCLK <= 1'd0; end
                19:begin SCLK <= 1'd1; end
                
                20:begin DIO <= SEL[5]; SCLK <= 1'd0; end
                21:begin SCLK <= 1'd1; end
                
                22:begin DIO <= SEL[4]; SCLK <= 1'd0; end
                23:begin SCLK <= 1'd1; end
                
                24:begin DIO <= SEL[3]; SCLK <= 1'd0; end
                25:begin SCLK <= 1'd1; end
                26:begin DIO <= SEL[2]; SCLK <= 1'd0; end
                27:begin SCLK <= 1'd1; end
                
                28:begin DIO <= SEL[1]; SCLK <= 1'd0; end
                29:begin SCLK <= 1'd1; end
                 
                30:begin DIO <= SEL[0]; SCLK <= 1'd0; end
                31:begin SCLK <= 1'd1; end
            endcase
        end
    end
    
    
endmodule

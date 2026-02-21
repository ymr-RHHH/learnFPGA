// ADC128S102 芯片的驱动逻辑

// 查数据手册知： ADC128S102 的工作频率在 8 MHz ~ 16 MHz
//  CS 在片选后需要有差不多有一个 10 ns ~ 30 ns 的窗口期
//  采样周期须经历 16 个 SCLK 周期

module ADC128S102_Driver(
    Addr,
    data,
    conv_go,      // 这里 conv_go 和 conv_done 这两个信号并不是一个连续信号
    conv_done,    // conv_go 是给 ADC128S102_Driver 模块一个脉冲，告诉它该
                  // 开始干活了，conv_done 同理。因为实际上你也不知道你在写
    CS_N,         // 控制的逻辑的时候要给conv信号一个怎样的时长
    SCLK,
    DIN,
    DOUT,
    
    clk,
    reset_n
    );
    
    input [2:0]Addr;
    output reg [11:0]data;
    input conv_go;
    output reg conv_done;
    output reg CS_N;
    output reg SCLK;
    output reg DIN;
    input DOUT;
    input clk;
    input reset_n;
    
    // 记录地址
    reg [2:0]r_Addr;
	
	always@(posedge clk)begin
	   if(conv_go)	
	   	r_Addr <= Addr;
	   else
	   	r_Addr <= r_Addr;
	end
	
    reg conv_en; 
    // 先搞定分频和节拍计数器
    // 这里将 ADC 的 SCLK 设置为 12.5 MHz ，这正好是 FPGA 的 50 MHz 的时钟的 4 分频
    reg [1:0] cnt_div_12_5MHz;
    parameter MCNT_12_5MHz = 2 - 1;
    // parameter CLOCK_FREQ = 50_000_000;
    // parameter SCLK_FREQ = 12_500_000;
    // parameter MCNT_DIV_CNT = CLOCK_FREQ / (SCLK_FREQ*2) - 1 ;
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)begin
            cnt_div_12_5MHz <= 0;
        end
        else if(conv_en)begin
            if(cnt_div_12_5MHz == MCNT_12_5MHz)
                cnt_div_12_5MHz <= 0;
            else
                cnt_div_12_5MHz <= cnt_div_12_5MHz + 1'd1;
        end
        else
            cnt_div_12_5MHz <= 0;
    end
    
    // 节拍计数器
    // 在 12.5 MHz 下，一周期为 80 ns，则 半周期 40 ns 正好大于 30 ns 的片选窗口期
    // 查数据手册知：采样一次需要 16 个 SCLK 周期
    // 则算上启动和关闭 片选 的时间，需要 2 + 16*2 = 34 个节拍
    reg [5:0] LSM_cnt;
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            LSM_cnt <= 0;
        else if(cnt_div_12_5MHz == MCNT_12_5MHz)begin
            if(LSM_cnt == 33)
                LSM_cnt <= 0;
            else
                LSM_cnt <= LSM_cnt + 1'd1;
        end
    end    
    
    // 转换使能
	always@(posedge clk or negedge reset_n )begin
	   if(!reset_n )
	   	conv_en <= 1'd0;
	   else if(conv_go)
	   	conv_en <= 1'd1;
	   else if((LSM_cnt == 6'd33) && (cnt_div_12_5MHz == MCNT_12_5MHz))
	   	conv_en <= 1'd0;
	   else
	   	conv_en <= conv_en;
    end
    
    
    // 线性序列机
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)begin
            CS_N <= 1;
            SCLK <= 1;
            DIN <= 0;
        end
        else if(conv_go)begin
             case(LSM_cnt)
                0:begin CS_N <= 0; end
                1:begin SCLK <= 0; DIN <= 0; end
                2:begin SCLK <= 1; end
                3:begin SCLK <= 0; end
                4:begin SCLK <= 1; end
                5:begin SCLK <= 0; DIN <= Addr[2]; end
                6:begin SCLK <= 1; end
                7:begin SCLK <= 0; DIN <= Addr[1]; end
                8:begin SCLK <= 1; end
                9:begin SCLK <= 0; DIN <= Addr[0];  end
                10:begin SCLK <= 1; data[11] <= DOUT; end  // 时序图上画的好像是上升沿读取一样，但是我特意查了一下，确实是下降沿读取，md，艹
                11:begin SCLK <= 0; end
                12:begin SCLK <= 1; data[10] <= DOUT; end
                13:begin SCLK <= 0; end
                14:begin SCLK <= 1; data[9] <= DOUT; end
                15:begin SCLK <= 0; end
                16:begin SCLK <= 1; data[8] <= DOUT; end
                17:begin SCLK <= 0; end
                18:begin SCLK <= 1; data[7] <= DOUT; end
                19:begin SCLK <= 0; end
                20:begin SCLK <= 1; data[6] <= DOUT; end
                21:begin SCLK <= 0; end
                22:begin SCLK <= 1; data[5] <= DOUT; end
                23:begin SCLK <= 0; end
                24:begin SCLK <= 1; data[4] <= DOUT; end
                25:begin SCLK <= 0; end
                26:begin SCLK <= 1; data[3] <= DOUT; end
                27:begin SCLK <= 0; end
                28:begin SCLK <= 1; data[2] <= DOUT; end
                29:begin SCLK <= 0; end
                30:begin SCLK <= 1; data[1] <= DOUT; end
                31:begin SCLK <= 0; end
                32:begin SCLK <= 1; data[0] <= DOUT; end
                33:begin CS_N <= 1; end
             endcase
        end
    end
    
    
    
    
endmodule

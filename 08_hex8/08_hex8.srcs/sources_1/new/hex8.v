module hex8(
    clk,
    reset_n,
    disp_Data,
    SEL,
    SEG
    );
    input clk;
    input reset_n;
    input [31:0]disp_Data;
    output reg [7:0]SEL;
    output reg [7:0]SEG;
    
    // 为了节省成本，这里利用余晖效应，通过快速地对数码管进行刷新来实现八个数码管同时显示不同的内容
    // 只要刷新率大于 60 Hz 人眼就看不出来到底这玩意到底是不是同时显示的
    // 为了方便估算，这里取 100 Hz，即每 10 ms 切换一次，数码管位选至少要 1.25 ms 切换一次，这里就索性取 1ms
    
    // 这里只要求 8 位 8段数码管 显示15进制数字即可
    // 如果想显示更多字符，可以自行扩大通道数据位宽和查找表容量
    
    // 1ms 计时模块
    parameter MCNT_1ms = 50_000 -1;
    reg [15:0] cnt_1ms;
    
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            cnt_1ms <= 1'd0;
        else if(cnt_1ms == MCNT_1ms)
            cnt_1ms <= 1'd0;
        else
            cnt_1ms <= cnt_1ms + 1'd1;
    end
    
    // 课程中段选位选用的是组合逻辑电路，但是我强迫症，非得写这个复位逻辑
    
    // 位选
    reg [2:0]cnt_sel;
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            cnt_sel <= 1'd0;
        else if(cnt_1ms == MCNT_1ms)
            cnt_sel <= cnt_sel + 1'd1;
    end
    
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            SEL <= 8'b1111_1111;
        else begin
            case(cnt_sel)
                7:SEL <= 8'b0000_0001;
                6:SEL <= 8'b0000_0010;
                5:SEL <= 8'b0000_0100;
                4:SEL <= 8'b0000_1000;
                3:SEL <= 8'b0001_0000;
                2:SEL <= 8'b0010_0000;
                1:SEL <= 8'b0100_0000;
                0:SEL <= 8'b1000_0000;
                default: SEL <= SEL;
            endcase
        end
    end
    
    
    // 段选
    reg [3:0]data_temp;
    always@(posedge clk)begin
        case(cnt_sel)
            7:data_temp <= disp_Data[3:0];
            6:data_temp <= disp_Data[7:4];
            5:data_temp <= disp_Data[11:8];
            4:data_temp <= disp_Data[15:12];
            3:data_temp <= disp_Data[19:16];
            2:data_temp <= disp_Data[23:20];
            1:data_temp <= disp_Data[27:24];
            0:data_temp <= disp_Data[31:28];
            default: data_temp <= data_temp;
        endcase
    end
    
    // 由于这里数码管显示16进制的编码纯粹与显示所需的led的排列组合有关，几乎没啥顺序
    // 所以这里直接用一个查找表实现，干净又卫生
    reg [7:0] seg;
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            seg <= 8'b1111_1111;
        else begin
            case(data_temp)
                4'h0: seg <= 8'b1100_0000;
                4'h1: seg <= 8'b1111_1001;
                4'h2: seg <= 8'b1010_0100;
                4'h3: seg <= 8'b1011_0000;
                4'h4: seg <= 8'b1001_1001;
                4'h5: seg <= 8'b1001_0010;
                4'h6: seg <= 8'b1000_0010;
                4'h7: seg <= 8'b1111_1000;
                4'h8: seg <= 8'b1000_0000;
                4'h9: seg <= 8'b1001_0000;
                4'ha: seg <= 8'b1000_1000;
                4'hb: seg <= 8'b1000_0011;
                4'hc: seg <= 8'b1100_0110;
                4'hd: seg <= 8'b1010_0001;
                4'he: seg <= 8'b1000_0110;
                4'hf: seg <= 8'b1000_1110;
                default: seg <= seg;
            endcase
        end
    end
    
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
           SEG <= 8'hff;
        else
           SEG <= seg;
    end


    
endmodule

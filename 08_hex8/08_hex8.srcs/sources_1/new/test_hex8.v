module test_hex8(
    clk,
    reset_n,
    DIO,
    SCLK,
    RCLK,
    sel
    );
    
    input clk;
    input reset_n;
    output DIO;
    input [1:0] sel;
    output SCLK;
    output RCLK;
    
    wire [7:0] SEL;
    wire [7:0] SEG;
    
    reg [31:0]disp_Data;
    
    HC595_Driver HC595_Driver_inst(
    .clk(clk),
    .reset_n(reset_n),
    .SEL(SEL),
    .SEG(SEG),
    .DIO(DIO),
    .SCLK(SCLK),
    .RCLK(RCLK)
    );

    hex8 hex8_inst (
    .clk(clk),
    .reset_n(reset_n),
    .disp_Data(disp_Data),
    .SEL(SEL),
    .SEG(SEG)
    );
    
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)
            disp_Data <= 0;
        else begin
            case(sel)
                0:disp_Data <= 32'h0123_4567;
                1:disp_Data <= 32'h89ab_cdef;
                2:disp_Data <= 32'habcd_ef12;
                3:disp_Data <= 32'h4567_89ab;
                default: disp_Data <= disp_Data;
            endcase
        end
    end
    
endmodule

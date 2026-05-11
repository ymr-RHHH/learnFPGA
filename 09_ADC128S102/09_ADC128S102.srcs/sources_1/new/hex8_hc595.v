module hex8_hc595(
    clk,
    reset_n,
    DIO,
    SCLK,
    RCLK,
    disp_data
    );
    
    input clk;
    input reset_n;
    output DIO;
    output SCLK;
    output RCLK;
    input[31:0] disp_data;
    
    
    wire [7:0] SEL;
    wire [7:0] SEG;
    
    
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
    .disp_Data(disp_data),
    .SEL(SEL),
    .SEG(SEG)
    );
    
        
endmodule




module ADC128S102_test(
    clk,
    reset_n,
    key,
    led,
    
    HEX8_DIO,
    HEX8_SCLK,
    HEX8_RCLK,
    
    ADC_SCLK,
    ADC_CS_N,
    ADC_DIN,
    ADC_DOUT
    );
    
    input clk;
    input reset_n;
    input key;
    output reg led;
    
    output HEX8_DIO;
    output HEX8_SCLK;
    output HEX8_RCLK;
    
    output ADC_SCLK;
    output ADC_CS_N;
    output ADC_DIN;
    input ADC_DOUT;
    
    wire conv_go;
    wire [2:0] Addr;
    assign Addr = 3'd0;
    
    wire conv_done;
    wire [11:0] ADC_data;
    
    wire [31:0] Disp_data;
    
    assign Disp_data = {20'd0,ADC_data};
    
    hex8_hc595 hex8_hc595_inst(
        .clk(clk),
        .reset_n(reset_n),
        .DIO(HEX8_DIO),
        .SCLK(HEX8_SCLK),
        .RCLK(HEX8_RCLK),
        .disp_data(Disp_data)
    );
    
    ADC128S102_Driver ADC128S102_Driver(
        .Addr(Addr),
        .data(ADC_data),
        .conv_go(conv_go),      
        .conv_done(conv_done),         
        .CS_N(ADC_CS_N),         
        .SCLK(ADC_SCLK),
        .DIN(ADC_DIN),
        .DOUT(ADC_DOUT),
        .clk(clk),
        .reset_n(reset_n)
    );
    
    wire Key_P_Flag;
    key_filter key_filter_inst(
    .clk(clk),
    .reset_n(reset_n),
    .key(key),
    .key_P_Flag(Key_P_Flag),
    .key_R_Flag(),
    .key_state()
    );
    
    assign conv_go = Key_P_Flag;
    
    always@(posedge clk or negedge reset_n)begin
        if(!reset_n)begin
            led <= 0;
        end
        else if(conv_done)begin
            led <= ~led;
        end
    end
    
    
endmodule

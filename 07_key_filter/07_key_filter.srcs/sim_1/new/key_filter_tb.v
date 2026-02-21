`timescale 1ns/1ns

module key_filter_tb;

    reg clk;
    reg reset_n;
    reg key;
    wire key_P_Flag;
    wire key_R_Flag;
    wire key_state;
    
    key_filter key_filter_inst(
        .clk(clk),
        .reset_n(reset_n),
        .key(key),
        .key_P_Flag(key_P_Flag),
        .key_R_Flag(key_R_Flag),
        .key_state(key_state)
        );
        
    initial clk = 0;
    always#10 clk = ~clk;
    
    initial begin
    reset_n = 0;
    key = 1;
    #201;
    
    reset_n = 1;
    
    // ÎÈ¶¨²âÊÔ
    key=0; #50_000_000;
    key=1; #50_000_000;
    key=0; #50_000_000;
    // ×´Ì¬»úÂË²¨²âÊÔ
    key=1; #1_000_000;
    key=0; #1_000_000;
    key=1; #2_000_000;
    key=0; #3_000_000;
    key=1; #100_000_000;
    key=0; #1_000_000;
    key=1; #3_000_000;
    key=0; #100_000_000;
    $stop;
    end
    
endmodule

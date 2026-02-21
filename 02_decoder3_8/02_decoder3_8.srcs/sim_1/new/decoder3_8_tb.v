`timescale 1ns / 1ns

module decoder3_8_tb();

reg [2:0] in;
wire [7:0] out;

decoder3_8 decoder3_8_ins0(
    .in(in),
    .out(out)
);


initial begin
    in = 3'd0;
    #20;
    in = 3'd1;
    #20;
    in = 3'd2;
    #20;
    in = 3'd3;
    #20;
    in = 3'd4;
    #20;
    in = 3'd5;
    #20;
    in = 3'd6;
    #20;
    in = 3'd7;
    #20;
    $stop;
end

endmodule

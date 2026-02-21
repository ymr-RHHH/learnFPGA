module mux2(  // 端口声明
    a,
    b,
    sel,
    out
);
    input a,b,sel;  // 端口定义
    output out;

    // 端口描述
    assign out = (sel == 0)? a : b ;

endmodule
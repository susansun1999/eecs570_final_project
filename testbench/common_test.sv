module common_test (
);

    logic [31:0] e;
    logic [31:0] r;


    initial begin
        e = 32'b1111101;
        r = S1(e);
        $display("r is %b", r);
    end
    
endmodule
module common_test (
);

    logic [31:0] e;
    logic [31:0] r;


    initial begin
        e = 32'b1111101;
        r = maj(1,2,3);
        $display("r is %b", r);
    end
    
endmodule
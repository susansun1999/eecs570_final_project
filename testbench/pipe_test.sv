module common_test (
);

    logic clk, reset, done;
    logic [0:63][31:0] W = '0;
    logic [0:7][31:0]  H_in = '0;
    logic [255:0] H_out;


    always begin
	#5;
        clk = ~clk;
    end

    Pipe myPipe(.H_in,
                  .W,
                  .clk,
                  .reset,
                  .done,
                  .H_out

    ); 

    initial begin
        clk = 0;
        reset = 1;
        @(posedge clk);
        @(posedge clk);
        reset = 0;
        wait(done == 1'b1);
        $display("H is %x", H_out);
        $display("done is %x", done);
        $finish;
    end
    
endmodule
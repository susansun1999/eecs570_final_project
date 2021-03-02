module testbench;

    logic clock, reset, requestA, requestB;
    logic [1:0] prediction;

    two_bit_pred tbp(.clock(clock), .reset(reset), .requestA(requestA),
                     .requestB(requestB), .prediction(prediction));

    always begin
        #5;
        clock=~clock;
    end

    initial begin

        $monitor("Time:%4.0f clock:%b reset:%b taken:%b transition:%b prediction:%b", 
                 $time, clock, reset, requestA,requestB, prediction);

        clock = 1'b0;
        reset = 1'b1;
        requestA = 1'b0;
        requestB = 1'b0;

        @(negedge clock);
        @(negedge clock);
        reset = 1'b0;
        @(negedge clock);
        requestA = 1'b1;
        @(negedge clock);
        @(negedge clock);
        requestA = 1'b0;
        @(negedge clock);
        requestB = 1'b1;
        requestA = 1'b1;
        @(negedge clock);
        requestA = 1'b0;
        #3 requestB = 1'b1;
        @(negedge clock);
        requestB = 1'b1;
        @(negedge clock);
        requestA = 1'b1;
        @(negedge clock);
        requestB = 1'b0;
        @(negedge clock);
        $finish;

    end

endmodule

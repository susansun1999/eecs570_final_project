//  Module: sha_tb
//  Author: Haichao Yang
//  Description: Testbench for SHA
// 
`timescale 1ns/1ps
module sha_tb;

    function logic [31:0] ROTR;
        input logic [31:0] x;
        input int n;
        n = n % 32;
        return (x >> n) | (x << (32-n));
    endfunction

    function logic [31:0] sigma0;
        input logic [31:0] x;
        return ROTR(x, 7) ^ ROTR(x, 18) ^ {3'h0, x[31:3]};
    endfunction

    function logic [31:0] sigma1;
        input logic [31:0] x;
        return ROTR(x, 17) ^ ROTR(x, 19) ^ {10'h0, x[31:10]};
    endfunction

    // function PrepairW64(logic [0:15] [31:0] W_in);
    //     logic [0:63] [31:0] W;
    //     int idx;
    //     W[0:15] = W_in;
    //     for (idx = 16; idx < 64; idx = idx + 1) begin
    //         W[idx] = sigma1(W[idx-2]) + W[idx-7] + sigma0(W[idx-15]) + W[idx-16];
    //     end
    //     return W;
    // endfunction

    task GetNextBlock;
        // output logic done;
        output logic [0:15] [31:0] msg_out;

        int idx;
        // done = 1'b1;
        msg_out[0] = 32'h87027980;
        for (idx = 1; idx < 15; idx = idx + 1) msg_out[idx] = 32'h0;
        msg_out[15] = 32'd24;
    endtask

    // task WaitUntilHigh;
    //     input signal;
    //     input clk;
    //     while (~signal) begin 
    //         @(negedge clk);
    //         if (signal) break;
    //         @(posedge clk);
    //     end
    //     $display("GB: %h; TEST: %h", result_gb, result_test);
    //     $finish;
    // endtask

    logic clk, reset;
    logic [0:7] [31:0] H_in, H_out;
    logic [0:15] [31:0] W_in;
    logic done_in, done_out_gb, done_out_test;
    logic [0:255] result, result_test, result_gb;
    logic [0:63] [31:0] W_in_64;

    logic[255:0] new_a;

    // Cnter test_module (
    //     .clk(clk),
    //     .reset(reset),
    //     .H_in(H_in),
    //     .W(W_in),
    //     .H_out(result_cnter),
    //     .done(done_out_gb)
    //     ,.test(new_a)
    // );

    Pipe tested_module (
        .clk(clk),
        .reset(reset),
        .H_in(H_in),
        .W(W_in_64),
        .H_out(result_test),
        .done(done_out_test)
        // ,.test(new_a)
    );

    // genvar gi;
    // generate
    //     for (gi = 0; gi < 8; gi = gi + 1) begin
    //         assign result[gi*32:gi*32+31] = H_out[gi];
    //     end
    // endgenerate


    always begin
        #100 clk = ~clk;
    end

    // always @(posedge clk) begin
    //     GetNextBlock(done_in, W_in);
    // end
    task get_W_IN_64;
        input [0:15] [31:0] W_in;
        output logic [0:63] [31:0] W_in_64;
        int idx;
        // always_comb begin
            W_in_64[0:15] = W_in;
            for (idx = 16; idx < 64; idx = idx + 1) begin
                W_in_64[idx] = sigma1(W_in_64[idx-2]) + W_in_64[idx-7] + sigma0(W_in_64[idx-15]) + W_in_64[idx-16];
            end
        // end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        W_in = 0;
        H_in = H0;
        // done_in = 0;
        GetNextBlock(W_in);
        get_W_IN_64(W_in, W_in_64);
        sha_hash_gb(H_in, W_in, result_gb);
        // $monitor("%x", new_a);
        @(posedge clk);
        @(negedge clk);
        reset = 0;
        @(posedge clk);
        // wait(done_out_gb)
        // result_gb = result;
        wait(done_out_test);
        $display("Golden Brick: %h\n        TEST: %h\n", result_gb, result_test);
        $finish;
    end
    
endmodule: sha_tb

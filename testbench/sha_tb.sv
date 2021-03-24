//  Module: sha_tb
//  Author: Haichao Yang
//  Description: Testbench for SHA
// 
`timescale 1ns/1ps
module sha_tb;
    task GetNextBlock;
        output logic done;
        output logic [0:15] [31:0] msg_out;

        int idx;
        done = 1'b1;
        msg_out[0] = 32'h87027980;
        for (idx = 1; idx < 15; idx = idx + 1) msg_out[idx] = 32'h0;
        msg_out[15] = 32'd24;
    endtask

    task WaitUntilHigh;
        input signal;
        input clk;
        while (~signal) begin 
            @(negedge clk);
            if (signal) break;
            @(posedge clk);
        end
        $display("GB: %h; TEST: %h", result_gb, result_test);
        $finish;
    endtask

    logic clk, reset;
    logic [0:7] [31:0] H_in, H_out;
    logic [0:15] [31:0] W_in;
    logic done_in, done_out_gb, done_out_test;
    logic [0:255] result, result_test, result_gb;

    logic[31:0] new_a;

    sha_hash_gb sha_hash_gb_0 (
        .clk(clk),
        .reset(reset),
        .H_in(H_in),
        .W_in(W_in),
        .H_out(H_out),
        .done_out(done_out_gb)
    );

    Cnter tested_module (
        .clk(clk),
        .reset(reset),
        .H_in(H_in),
        .W(W_in),
        .H_out(result_test),
        .done(done_out_test),
        .test(new_a)
    );

    genvar gi;
    generate
        for (gi = 0; gi < 8; gi = gi + 1) begin
            assign result[gi*32:gi*32+31] = H_out[gi];
        end
    endgenerate


    always begin
        #100 clk = ~clk;
    end

    always @(posedge clk) begin
        GetNextBlock(done_in, W_in);
    end

    always_comb begin

    end

    initial begin
        clk = 0;
        reset = 1;
        W_in = '0;
        H_in = 0;
        done_in = 0;
        $monitor("%x", new_a);
        @(posedge clk);
        @(negedge clk);
        reset = 0;
        H_in = H0;
        @(posedge clk);
        wait(done_out_gb)
        result_gb = result;
        wait(done_out_test);
        $display("Golden Brick: %h\n        TEST: %h", result_gb, result_test);
        $finish;
    end
    
endmodule: sha_tb

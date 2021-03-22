//  Module: sha_hash_gb
//  Author: Haichao Yang
//  Description: Calculates Hash Results
//  
`timescale 1ns/1ps
module sha_hash_gb
    (
        input clk, reset,
        input [0:7] [31:0] H_in,
        input [15:0] [31:0] W_in,
        output logic [7:0] [31:0] H_out,
        output logic done_out
    );

    function logic [31:0] ROTR;
        input logic [31:0] x;
        input int n;
        n = n % 32;
        return (x >> n) | (x << (32-n));
    endfunction

    function logic [31:0] Sigma0;
        input logic [31:0] x;
        return ROTR(x, 2) ^ ROTR(x, 13) ^ ROTR(x, 22);
    endfunction
    
    function logic [31:0] Sigma1;
        input logic [31:0] x;
        return ROTR(x, 6) ^ ROTR(x, 11) ^ ROTR(x, 25);
    endfunction

    function logic [31:0] sigma0;
        input logic [31:0] x;
        return ROTR(x, 7) ^ ROTR(x, 18) ^ {3'h0, x[31:3]};
    endfunction

    function logic [31:0] sigma1;
        input logic [31:0] x;
        return ROTR(x, 17) ^ ROTR(x, 19) ^ {10'h0, x[31:10]};
    endfunction

    function logic [31:0] Ch;
        input logic [31:0] x, y, z;
        return (x & y) ^ (~x & z);
    endfunction

    function logic [31:0] Maj;
        input logic [31:0] x, y, z;
        return (x & y) ^ (x & z) ^ (y & z);
    endfunction

    function logic [0:7] [31:0] Hash;
        input [0:7] [31:0] H_in;
        input [0:15] [31:0] W_in;

        logic [0:63] [31:0] W;
        int idx;
        logic [31:0] a, b, c, d, e, f, g, h, T1, T2;
        logic [0:7] [31:0] H_out;

        // Prepair W
        W[0:15] = W_in;
        for (idx = 16; idx < 64; idx = idx + 1) begin
            W[idx] = sigma1(W[idx-2]) + W[idx-7] + sigma0(W[idx-15]) + W[idx-16];
        end

        // Initialize a to h
        a = H_in[0];
        b = H_in[1];
        c = H_in[2];
        d = H_in[3];
        e = H_in[4];
        f = H_in[5];
        g = H_in[6];
        h = H_in[7];

        // loop
        for (idx = 0; idx < 64; idx = idx + 1) begin
            T1 = h + Sigma1(e) + Ch(e, f, g) + K[idx] + W[idx];
            T2 = Sigma0(a) + Maj(a, b, c);
            h = g;
            g = f;
            f = e;
            e = d + T1;
            d = c;
            c = b;
            b = a;
            a = T1 + T2;
        end

        H_out[0] = H_in[0] + a;
        H_out[1] = H_in[1] + b;
        H_out[2] = H_in[2] + c;
        H_out[3] = H_in[3] + d;
        H_out[4] = H_in[4] + e;
        H_out[5] = H_in[5] + f;
        H_out[6] = H_in[6] + g;
        H_out[7] = H_in[7] + h;
        
        return H_out;
    endfunction
    
    always_comb begin
        H_out = Hash(H_in, W_in);
        done_out = 1'b1;
    end
    
endmodule: sha_hash_gb


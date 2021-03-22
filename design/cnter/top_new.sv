function automatic [3:0]get_index;
    input  [3:0] counter_mod;
    input  [3:0] a, b, c, d, e, f, g, h;
    case (counter_mod)
        4'b0: get_index = a;
        4'b1: get_index = b;
        4'b10: get_index = c;
        4'b11: get_index = d;
        4'b100: get_index = e;
        4'b101: get_index = f;
        4'b110: get_index = g;
        4'b111: get_index = h;
        default: get_index = b;
    endcase
    
endfunction

module Cnter (
    input [0:7][31:0]  H_in,
    input [0:63][31:0] W,
    // input logic [0:63][31:0] K,
    input clk,
    input reset,
    output logic done,
    output logic [255:0] H_out
    // output  logic [31:0] test
);
    // enum {A, B, C, D, E, F, G, H} Place;

    logic [0:63][31:0] K;
    
    assign K = {32'h428a2f98, 32'h71374491, 32'hb5c0fbcf, 32'he9b5dba5, 32'h3956c25b, 32'h59f111f1, 32'h923f82a4, 32'hab1c5ed5,
                            32'hd807aa98, 32'h12835b01, 32'h243185be, 32'h550c7dc3, 32'h72be5d74, 32'h80deb1fe, 32'h9bdc06a7, 32'hc19bf174,
                            32'he49b69c1, 32'hefbe4786, 32'h0fc19dc6, 32'h240ca1cc, 32'h2de92c6f, 32'h4a7484aa, 32'h5cb0a9dc, 32'h76f988da,
                            32'h983e5152, 32'ha831c66d, 32'hb00327c8, 32'hbf597fc7, 32'hc6e00bf3, 32'hd5a79147, 32'h06ca6351, 32'h14292967,
                            32'h27b70a85, 32'h2e1b2138, 32'h4d2c6dfc, 32'h53380d13, 32'h650a7354, 32'h766a0abb, 32'h81c2c92e, 32'h92722c85,
                            32'ha2bfe8a1, 32'ha81a664b, 32'hc24b8b70, 32'hc76c51a3, 32'hd192e819, 32'hd6990624, 32'hf40e3585, 32'h106aa070,
                            32'h19a4c116, 32'h1e376c08, 32'h2748774c, 32'h34b0bcb5, 32'h391c0cb3, 32'h4ed8aa4a, 32'h5b9cca4f, 32'h682e6ff3,
                            32'h748f82ee, 32'h78a5636f, 32'h84c87814, 32'h8cc70208, 32'h90befffa, 32'ha4506ceb, 32'hbef9a3f7, 32'hc67178f2};

 

    logic [7:0] counter, counter2;
    logic [0:7][31:0] result;
    logic [0:7][31:0] new_result;
    logic [31:0] new_a;
    logic [31:0] new_e;
    logic [31:0] temp1, temp2;
    logic [31:0] W_reg;
    logic [3:0] counter_mod;
    logic [3:0] a,b,c,d,e,f,g,h;
    // logic [3:0] new_a_idx, new_e_idx;
   
    assign a = get_index(counter_mod, 0, 7, 6, 5, 4, 3, 2, 1);
    assign b = get_index(counter_mod, 1, 0, 7, 6, 5, 4, 3, 2);
    assign c = get_index(counter_mod, 2, 1, 0, 7, 6, 5, 4, 3);
    assign d = get_index(counter_mod, 3, 2, 1, 0, 7, 6, 5, 4);
    assign e = get_index(counter_mod, 4, 3, 2, 1, 0, 7, 6, 5);
    assign f = get_index(counter_mod, 5, 4, 3, 2, 1, 0, 7, 6);
    assign g = get_index(counter_mod, 6, 5, 4, 3, 2, 1, 0, 7);
    assign h = get_index(counter_mod, 7, 6, 5, 4, 3, 2, 1, 0);
    assign counter_mod = counter & 4'b111;
 
    // assign temp1 = result[h] + S1(result[e]) + ch(result[e], result[f], result[g]) + K[counter2] + W_reg;
    // assign temp2 = S0(result[a]) + maj(result[a], result[b], result[c]);
    // assign new_a = temp1 + temp2;
    // assign new_e = result[d] + temp1;
    assign temp1 = result[h] + S1(new_e) + ch(new_e, result[f], result[g]) + K[counter2] + W_reg;
    assign temp2 = S0(new_a) + maj(new_a, result[b], result[c]);



    always_comb begin
        new_result = result;
        for(int i = 0; i < 8; i++)begin
            if(i == a) new_result[i] = new_a;
            else if(i == e) new_result[i] = new_e;
        end
    end


    always_ff @(posedge clk) begin
        if (reset) begin
            counter <=  8'b0;
            counter2 <=  8'b0;
            result  <=  H_in;
            W_reg   <=  W[0];
            new_a   <=  H_in[0];
            new_e   <=  H_in[4];
        end else begin
            counter <= counter + 1'b1;
            counter2 <= counter2 + 1'b1;
            result  <= new_result;
            W_reg   <= W[counter2];
            new_a   <= temp1 + temp2;
            new_e   <= result[d] + temp1;
        end
    end

    assign done = counter == 7'd65;
    assign H_out = result;
    // assign test = K[counter]; //get_index has issue
    
endmodule
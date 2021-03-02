module Cnter (
    input [0:7][31:0]  H_in,
    input [0:63][31:0] W,
    input clk,
    input reset,
    output logic done,
    output logic [255:0] H_out
);
    enum {A, B, C, D, E, F, G, H} Place;

    logic [0:63][31:0] K = {32'h428a2f98, 32'h71374491, 32'hb5c0fbcf, 32'he9b5dba5, 32'h3956c25b, 32'h59f111f1, 32'h923f82a4, 32'hab1c5ed5,
                            32'hd807aa98, 32'h12835b01, 32'h243185be, 32'h550c7dc3, 32'h72be5d74, 32'h80deb1fe, 32'h9bdc06a7, 32'hc19bf174,
                            32'he49b69c1, 32'hefbe4786, 32'h0fc19dc6, 32'h240ca1cc, 32'h2de92c6f, 32'h4a7484aa, 32'h5cb0a9dc, 32'h76f988da,
                            32'h983e5152, 32'ha831c66d, 32'hb00327c8, 32'hbf597fc7, 32'hc6e00bf3, 32'hd5a79147, 32'h06ca6351, 32'h14292967,
                            32'h27b70a85, 32'h2e1b2138, 32'h4d2c6dfc, 32'h53380d13, 32'h650a7354, 32'h766a0abb, 32'h81c2c92e, 32'h92722c85,
                            32'ha2bfe8a1, 32'ha81a664b, 32'hc24b8b70, 32'hc76c51a3, 32'hd192e819, 32'hd6990624, 32'hf40e3585, 32'h106aa070,
                            32'h19a4c116, 32'h1e376c08, 32'h2748774c, 32'h34b0bcb5, 32'h391c0cb3, 32'h4ed8aa4a, 32'h5b9cca4f, 32'h682e6ff3,
                            32'h748f82ee, 32'h78a5636f, 32'h84c87814, 32'h8cc70208, 32'h90befffa, 32'ha4506ceb, 32'hbef9a3f7, 32'hc67178f2};


    logic [7:0] counter;
    logic [0:7][31:0] result;
    logic [0:7][31:0] new_result;
    logic [31:0] new_a;
    logic [31:0] new_e;
    logic [31:0] temp1, temp2;
    logic [3:0] new_a_idx, new_e_idx;
    logic [0:7][3:0] idx_array;
 
    assign temp1 = result[idx_array[Place.H]] + S1(result[idx_array[Place.E]]) + ch(result[idx_array[Place.E]], result[idx_array[Place.F]], result[idx_array[Place.G]]) + K[counter] + W[counter];
    assign temp2 = S0(result[idx_array[Place.A]]) + maj(result[idx_array[Place.A]], result[idx_array[Place.B]], result[idx_array[Place.C]]);
    assign new_a = temp1 + temp2;
    assign new_e = result[idx_array[Place.D]] + temp1;
    assign new_a_idx = 3'd7 - counter & 3'b111;
    assign new_e_idx = (counter & 3'b111) >= 3'd4 ? 4'd11 -  (counter & 3'b111) : 3'd3 - (counter & 3'b111);


    always_comb begin
        new_result = result;
        for(int i = 0; i < 8; i++)begin
            if(i == new_a_idx) new_result[i] = new_a;
            else if(i == new_e_idx) new_result[i] = new_e;
            idx_array[i] = (counter & 3'b111) > i ? i + 4'd8 - (counter & 3'b111) : i - (counter & 3'b111);
        end
    end


    always @(posedge clk) begin
        if (reset) begin
            counter <= 8'b0;
            result  <= H_in;
        end else begin
            counter <= counter + 1'b1;
            result  <= new_result;
        end
    end

    assign done = counter == 7'd64;
    assign H_out = result;

    
endmodule
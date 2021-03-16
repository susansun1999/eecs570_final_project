`timescale 1ns/1ps
module common_test (
);

    logic clk, reset, done;
    logic [0:63][31:0] W = 0;
    logic [0:7][31:0]  H_in = 1;
    logic [255:0] H_out;
    logic [31:0] test;
    logic [0:63][31:0] K = {32'h428a2f98, 32'h71374491, 32'hb5c0fbcf, 32'he9b5dba5, 32'h3956c25b, 32'h59f111f1, 32'h923f82a4, 32'hab1c5ed5,
                        32'hd807aa98, 32'h12835b01, 32'h243185be, 32'h550c7dc3, 32'h72be5d74, 32'h80deb1fe, 32'h9bdc06a7, 32'hc19bf174,
                        32'he49b69c1, 32'hefbe4786, 32'h0fc19dc6, 32'h240ca1cc, 32'h2de92c6f, 32'h4a7484aa, 32'h5cb0a9dc, 32'h76f988da,
                        32'h983e5152, 32'ha831c66d, 32'hb00327c8, 32'hbf597fc7, 32'hc6e00bf3, 32'hd5a79147, 32'h06ca6351, 32'h14292967,
                        32'h27b70a85, 32'h2e1b2138, 32'h4d2c6dfc, 32'h53380d13, 32'h650a7354, 32'h766a0abb, 32'h81c2c92e, 32'h92722c85,
                        32'ha2bfe8a1, 32'ha81a664b, 32'hc24b8b70, 32'hc76c51a3, 32'hd192e819, 32'hd6990624, 32'hf40e3585, 32'h106aa070,
                        32'h19a4c116, 32'h1e376c08, 32'h2748774c, 32'h34b0bcb5, 32'h391c0cb3, 32'h4ed8aa4a, 32'h5b9cca4f, 32'h682e6ff3,
                        32'h748f82ee, 32'h78a5636f, 32'h84c87814, 32'h8cc70208, 32'h90befffa, 32'ha4506ceb, 32'hbef9a3f7, 32'hc67178f2};


    always begin
	#5;
        clk = ~clk;
    end

    Cnter myCnter(.H_in,
                  .W,
                //   .K,
                  .clk,
                  .reset,
                  .done,
                  .H_out
                //   .test

    ); 

    initial begin
        // $set_toggle_region(common_test);
        // $toggle_start();
        clk = 0;
        reset = 1;
        @(negedge clk);
        reset = 0;
        // @(posedge clk);
        // $display("H is %x", H_out);
        // $display("test is %x", test);
        wait(done == 1'b1);
        // @(posedge clk);
        // $display("H is %x", H_out);
        // $display("test is %x", test);
        // @(posedge clk);
        // $display("H is %x", H_out);
        //  $display("test is %x", test);
        // @(posedge clk);
        // $display("H is %x", H_out);
        //  $display("test is %x", test);
        // @(posedge clk);
        // $display("H is %x", H_out);
        //  $display("test is %x", test);
        // @(posedge clk);
        // $display("H is %x", H_out);
        //  $display("test is %x", test);
        // @(posedge clk);
        // $display("H is %x", H_out);
        //  $display("test is %x", test);
        // @(posedge clk);
        // $display("H is %x", H_out);
        //  $display("test is %x", test);
        @(posedge clk);
        $display("H is %x", H_out); // synthesis has bug
        $display("done is %x", done);
        // $toggle_stop();
        // $toggle_report("power.saif", 1.0e-12, "common_test ");
        $finish;
    end
    
endmodule
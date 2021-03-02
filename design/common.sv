virtual class math#(parameter length);
    static function [31:0] rightrotate;
        input [31:0] e;
        for(int i = 0; i < 32; i=i+1) begin
            rightrotate[i] = i < (32-length) ? e[length+i] : e[i-(32-length)];
        end 
    endfunction
endclass 

function [31:0] S1;
    input [31:0] e;
    S1 = math#(6)::rightrotate(e) ^ math#(11)::rightrotate(e) ^ math#(25)::rightrotate(e);
endfunction

function [31:0] S0;
    input [31:0] a;
    S0 = math#(2)::rightrotate(a) ^ math#(13)::rightrotate(a) ^ math#(22)::rightrotate(a);
endfunction

function [31:0] ch;
    input [31:0] e;
    input [31:0] f;
    input [31:0] g;
    ch = (e & f) ^ ( (~e) & g);
endfunction

function [31:0] maj;
    input [31:0] a;
    input [31:0] b;
    input [31:0] c;
    maj = (a & b) ^ (a & c) ^ (b & c);
endfunction
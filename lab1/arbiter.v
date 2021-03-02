module two_bit_pred(
        input clock, reset, requestA, requestB, 
        output [1:0] prediction); 


    logic [1:0] state; 
    logic [1:0] next_state;

    assign prediction = state; 

    always_comb begin 
      case(state) 
        2'b00 : next_state = requestA ? 2'b01 : (requestB ? 2'b10 : 2'b00);
        2'b01 : next_state = requestA ? 2'b01 : 2'b00;
        2'b10 : next_state = requestB ? 2'b10 : 2'b00; 
        2'b11 : next_state = 2'b00; 
      endcase 
    end 

    always_ff @(posedge clock) begin 
      if(reset) 
        state <= #1 2'b00; 
      else
        state <= #1 next_state; 
    end 

endmodule
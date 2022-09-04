`include "ranc_defines.vh"

module counter (
    input            clk    , // Clock signal
    input            reset_n, // Asynchronous reset
    input            wen    , // Write enable
    output reg [3:0] out      // Counter
);
    always@(negedge clk, negedge reset_n) begin
        if(~reset_n) begin
          out <= 4'b1111;
        end else if(wen) begin
          out <= out + 1;
        end
    end
   
endmodule

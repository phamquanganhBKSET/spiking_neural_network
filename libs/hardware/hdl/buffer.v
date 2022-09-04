//////////////////////////////////////////////////////////////////////////////////
// buffer.v
//
// A simple buffer.
// Reads and writes are synchronous
// Reset is synchronous active high.
//
// NOTE: BUFFER_DEPTH has to be a power of 2 
// (Don't forget 1 is also a power of 2 :-) ).
//////////////////////////////////////////////////////////////////////////////////

`include "ranc_defines.vh"

module buffer #(
    parameter DATA_WIDTH   = `DATA_WIDTH  ,
    parameter BUFFER_DEPTH = `BUFFER_DEPTH,
    parameter BUFFER_WIDTH = `BUFFER_WIDTH 
)(
    input                   clk      , // Clock signal
    input                   reset_n  , // Asynchronous reset, active low
    input  [DATA_WIDTH-1:0] din      , // Data in
    input                   din_valid, // Data in valid
    input                   read_en  , // Read enable
    output [DATA_WIDTH-1:0] dout     , // Data out
    output                  empty    , // Empty flag
    output                  full       // Full flag
);

    /* 
    If BUFFER_DEPTH is 1 the logic needs to be different
    as read_pointer / write_pointer should not be used. Using
    generate statement to correctly generate logic 
    */

    reg [DATA_WIDTH-1:0  ] data          [BUFFER_DEPTH-1:0]; // Data memory
    reg [BUFFER_WIDTH-1:0] read_pointer                    ; // Read pointer
    reg [BUFFER_WIDTH-1:0] write_pointer                   ; // Write pointer
    reg [BUFFER_WIDTH:0  ] status_counter                  ; // Status counter
    reg [DATA_WIDTH-1:0  ] output_data                     ; // Data out
    
    assign empty = (status_counter == 0)           ;
    assign full  = (status_counter == BUFFER_DEPTH);
    assign dout  = output_data                     ;

    integer i;
    always@(posedge clk, negedge reset_n) begin
        if (~reset_n) begin
            for (i = 0; i < BUFFER_DEPTH; i = i + 1)
              data[i]        <= 0;
              read_pointer   <= 0;
              write_pointer  <= 0;
              status_counter <= 0;
              output_data    <= 0;
        end
        else begin
            if (!full && din_valid) begin
                data[write_pointer] <= din;
                write_pointer       <= write_pointer + 1;
            end
            if (read_en && !empty) begin
                output_data  <= data[read_pointer];
                read_pointer <= read_pointer + 1;
            end
            if(!full && din_valid && read_en && !empty) begin
                status_counter <= status_counter;
            end
            else if((!full && din_valid) && !(read_en && !empty)) begin
                status_counter <= status_counter + 1;
            end
            else if(!(!full && din_valid) && (read_en && !empty)) begin
                status_counter <= status_counter - 1;
            end
        end
    end

endmodule

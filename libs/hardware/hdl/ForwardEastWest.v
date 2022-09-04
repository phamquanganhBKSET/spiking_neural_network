//////////////////////////////////////////////////////////////////////////////////
// ForwardEastWest.v
//
// The router forwarding modules for either Forward East or Forward East.
//
// If forward east, set EAST to 1. If forward west, set EAST to 0.
// BUFFER_DEPTH must be a power of 2.
//////////////////////////////////////////////////////////////////////////////////

`include "ranc_defines.vh"

module ForwardEastWest #(
    parameter PACKET_WIDTH = `PACKET_WIDTH,
    parameter DX_MSB       = `DX_MSB      ,
    parameter DX_LSB       = `DX_LSB      ,
    parameter DY_MSB       = `DY_MSB      ,
    parameter DY_LSB       = `DY_LSB      ,
    parameter BUFFER_DEPTH = `BUFFER_DEPTH,
    parameter EAST         = `EAST         
)(
    input                                     clk                     ,
    input                                     reset_n                 ,
    input  [PACKET_WIDTH-1:0                ] din_routing             ,
    input  [PACKET_WIDTH-1:0                ] din_token_controller    ,
    input                                     empty_routing           ,
    input                                     ren_in_north            ,
    input                                     empty_token_controller  ,
    input                                     ren_in_routing          ,
    input                                     ren_in_south            ,
    output                                    ren_out_routing         ,
    output                                    ren_out_token_controller,
    output [PACKET_WIDTH-1:0                ] dout_routing            ,
    output                                    routing_buffer_empty    ,
    output [PACKET_WIDTH-1-(DX_MSB-DY_MSB):0] dout_north              ,
    output                                    north_buffer_empty      ,
    output [PACKET_WIDTH-1-(DX_MSB-DY_MSB):0] dout_south              ,
    output                                    south_buffer_empty       
);

    localparam ADD = EAST ? -1 : 1;

    wire                                    buffers_full       ;
    wire [PACKET_WIDTH-1:0                ] merge_out          ;
    wire                                    merge_out_wen      ;
    wire [PACKET_WIDTH-1:0                ] routing_buffer_in  ;
    wire                                    routing_buffer_wen ;
    wire [PACKET_WIDTH-1-(DX_MSB-DY_MSB):0] north_buffer_in    ;
    wire                                    north_buffer_wen   ;
    wire [PACKET_WIDTH-1-(DX_MSB-DY_MSB):0] south_buffer_in    ;
    wire                                    south_buffer_wen   ;
    wire                                    routing_buffer_full;
    wire                                    north_buffer_full  ;
    wire                                    south_buffer_full  ;

    assign buffers_full = routing_buffer_full | north_buffer_full | south_buffer_full;

    Merge2 #(
        .DATA_WIDTH(PACKET_WIDTH)
    ) Merge (
        .clk(clk),
        .reset_n(reset_n),
        .din_a(din_routing),
        .buffer_a_empty(empty_routing),
        .din_b(din_token_controller),
        .buffer_b_empty(empty_token_controller),
        .buffer_out_full(buffers_full),
        .read_en_a(ren_out_routing),
        .read_en_b(ren_out_token_controller),
        .dout(merge_out),
        .wen(merge_out_wen)
    );
    
    PathDecoder3Way #(
        .DATA_WIDTH(PACKET_WIDTH),
        .DX_MSB    (DX_MSB      ),
        .DX_LSB    (DX_LSB      ),
        .DY_MSB    (DY_MSB      ),
        .DY_LSB    (DY_LSB      ),
        .ADD       (ADD         )
    ) PathDecoder (
        .din(merge_out),
        .wen(merge_out_wen),
        .dout_a(routing_buffer_in),
        .wen_a(routing_buffer_wen),
        .dout_b(north_buffer_in),
        .wen_b(north_buffer_wen),
        .dout_c(south_buffer_in),
        .wen_c(south_buffer_wen)
    );
    
    buffer #(
        .DATA_WIDTH  (PACKET_WIDTH),
        .BUFFER_DEPTH(BUFFER_DEPTH)
    ) routing_buffer (
        .clk(clk),
        .reset_n(reset_n),
        .din(routing_buffer_in),
        .din_valid(routing_buffer_wen),
        .read_en(ren_in_routing),
        .dout(dout_routing),
        .empty(routing_buffer_empty),
        .full(routing_buffer_full)
    );
    
    buffer #(
        .DATA_WIDTH(PACKET_WIDTH-(DX_MSB-DY_MSB)),
        .BUFFER_DEPTH(BUFFER_DEPTH)
    ) north_buffer (
        .clk(clk),
        .reset_n(reset_n),
        .din(north_buffer_in),
        .din_valid(north_buffer_wen),
        .read_en(ren_in_north),
        .dout(dout_north),
        .empty(north_buffer_empty),
        .full(north_buffer_full)
    );
    
    buffer #(
        .DATA_WIDTH(PACKET_WIDTH-(DX_MSB-DY_MSB)),
        .BUFFER_DEPTH(BUFFER_DEPTH)
    ) south_buffer (
        .clk(clk),
        .reset_n(reset_n),
        .din(south_buffer_in),
        .din_valid(south_buffer_wen),
        .read_en(ren_in_south),
        .dout(dout_south),
        .empty(south_buffer_empty),
        .full(south_buffer_full)
    );
        
    
endmodule

//---------------------------------------------------------------
// ??????: uart_top
// ??????????? : ??’???? ????? baud_gen, uart_tx ?? uart_rx
//---------------------------------------------------------------
module uart_top (
    input  wire clk,
    input  wire reset,
    input  wire tx_start,
    input  wire [7:0] data_in,
    output wire txd,
    input  wire rxd,
    output wire [7:0] data_out,
    output wire data_valid
);
    wire tick;

    baud_gen #(.CLK_FREQ(50000000), .BAUD_RATE(9600)) baud_inst (
        .clk(clk),
        .reset(reset),
        .tick(tick)
    );

    uart_tx tx_inst (
        .clk(clk),
        .reset(reset),
        .tick(tick),
        .tx_start(tx_start),
        .data_in(data_in),
        .txd(txd),
        .tx_done()
    );

    uart_rx rx_inst (
        .clk(clk),
        .reset(reset),
        .tick(tick),
        .rxd(rxd),
        .data_out(data_out),
        .data_valid(data_valid)
    );
endmodule

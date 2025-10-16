//---------------------------------------------------------------
// МОДУЛЬ: uart_top
// Призначення : з’єднує разом модулі baud_gen, uart_tx та uart_rx
//---------------------------------------------------------------
module uart_top (
    input  wire clk,             // системний такт
    input  wire reset,           // сигнал скидання
    input  wire tx_start,        // сигнал початку передачі
    input  wire [7:0] data_in,   // байт даних для передачі
    output wire txd,             // вихідна лінія UART (передавач)
    input  wire rxd,             // вхідна лінія UART (приймач)
    output wire [7:0] data_out,  // прийнятий байт даних
    output wire data_valid       // сигнал готовності прийнятих даних
);
    wire tick; // сигнал тактування baud_tick від дільника частоти

    // --- Інстанціювання дільника частоти ---
    baud_gen #(
        .CLK_FREQ(50000000),    // частота системного такту 50 МГц
        .BAUD_RATE(9600)        // швидкість передачі 9600 бод
    ) baud_inst (
        .clk(clk),
        .reset(reset),
        .tick(tick)
    );

    // --- Інстанціювання передавача ---
    uart_tx tx_inst (
        .clk(clk),
        .reset(reset),
        .tick(tick),
        .tx_start(tx_start),
        .data_in(data_in),
        .txd(txd),
        .tx_done()              // не використовується в цьому модулі
    );

    // --- Інстанціювання приймача ---
    uart_rx rx_inst (
        .clk(clk),
        .reset(reset),
        .tick(tick),
        .rxd(rxd),
        .data_out(data_out),
        .data_valid(data_valid)
    );
endmodule

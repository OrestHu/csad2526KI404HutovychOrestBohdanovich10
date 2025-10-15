//---------------------------------------------------------------
// МОДУЛЬ: uart_tx
// Призначення : послідовна передача байта через лінію UART
// FSM: IDLE → START → DATA → STOP
//---------------------------------------------------------------
module uart_tx (
    input  wire clk,          // системний такт
    input  wire reset,        // скидання
    input  wire tick,         // імпульс baud_rate
    input  wire tx_start,     // почати передачу
    input  wire [7:0] data_in,// байт для передачі
    output reg  txd,          // вихід UART
    output reg  tx_done       // прапорець завершення
);

    // Коди станів
    typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;
    state_t state;
    reg [7:0] shreg;          // зсувний регістр даних
    reg [2:0] bit_cnt;        // лічильник біта

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            txd <= 1;
            tx_done <= 0;
            shreg <= 0;
            bit_cnt <= 0;
        end else begin
            case (state)
                IDLE: begin
                    txd <= 1; tx_done <= 0;
                    if (tx_start) begin
                        shreg <= data_in;
                        bit_cnt <= 0;
                        state <= START;
                    end
                end
                START: begin
                    txd <= 0;                 // стартовий біт
                    if (tick) state <= DATA;
                end
                DATA: begin
                    if (tick) begin
                        txd <= shreg[0];     // передаємо LSB
                        shreg <= {1'b0, shreg[7:1]};
                        bit_cnt <= bit_cnt + 1;
                        if (bit_cnt == 7) state <= STOP;
                    end
                end
                STOP: begin
                    txd <= 1;                 // стоповий біт
                    if (tick) begin
                        tx_done <= 1;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule

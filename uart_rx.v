//---------------------------------------------------------------
// МОДУЛЬ: uart_rx
// Призначення : прийом послідовних бітів UART і відновлення байта
// FSM: IDLE → START → DATA → STOP → READY
//---------------------------------------------------------------
module uart_rx (
    input  wire clk,
    input  wire reset,
    input  wire tick,           // baud_tick
    input  wire rxd,            // вхід UART
    output reg  [7:0] data_out, // прийнятий байт
    output reg  data_valid      // сигнал готовності
);

    typedef enum logic [2:0] {IDLE, START, DATA, STOP, READY} state_t;
    state_t state;
    reg [7:0] shreg;
    reg [2:0] bit_cnt;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            data_valid <= 0;
            shreg <= 0;
            bit_cnt <= 0;
            data_out <= 0;
        end else begin
            case (state)
                IDLE: if (!rxd) state <= START;      // виявлено старт
                START: if (tick) state <= DATA;      // середина біта
                DATA: if (tick) begin
                    shreg <= {rxd, shreg[7:1]};
                    bit_cnt <= bit_cnt + 1;
                    if (bit_cnt == 7) state <= STOP;
                end
                STOP: if (tick) state <= READY;      // перевіряємо стоп-біт
                READY: begin
                    data_out <= shreg;
                    data_valid <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule

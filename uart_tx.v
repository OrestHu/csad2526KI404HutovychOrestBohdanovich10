//---------------------------------------------------------------
// МОДУЛЬ: uart_tx
// Призначення : послідовна передача байта через лінію UART
//---------------------------------------------------------------
module uart_tx (
    input  wire clk,         // системний такт
    input  wire reset,       // скидання
    input  wire tick,        // імпульс baud_rate
    input  wire tx_start,    // сигнал початку передачі
    input  wire [7:0] data_in, // байт для передачі
    output reg  txd,         // вихідна лінія UART
    output reg  tx_done      // сигнал завершення передачі
);

    // --- стани FSM ---
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0] state;       // поточний стан
    reg [7:0] shreg;       // зсувний регістр даних
    reg [2:0] bit_cnt;     // лічильник біта

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state   <= IDLE;
            txd     <= 1'b1;
            tx_done <= 1'b0;
            bit_cnt <= 3'd0;
            shreg   <= 8'd0;
        end else begin
            case (state)
                IDLE: begin
                    txd <= 1'b1;
                    tx_done <= 1'b0;
                    if (tx_start) begin
                        shreg <= data_in;      // завантаження байта
                        bit_cnt <= 3'd0;       // обнулення лічильника
                        state <= START;        // перехід у стан START
                    end
                end

                START: begin
                    txd <= 1'b0;               // стартовий біт
                    if (tick)
                        state <= DATA;         // після одного такту → DATA
                end

                DATA: begin
                    if (tick) begin
                        txd <= shreg[0];       // передаємо LSB
                        shreg <= {1'b0, shreg[7:1]}; // зсув праворуч
                        if (bit_cnt == 3'd7)
                            state <= STOP;     // передано 8 бітів → STOP
                        else
                            bit_cnt <= bit_cnt + 1'b1;
                    end
                end

                STOP: begin
                    txd <= 1'b1;               // стоповий біт
                    if (tick) begin
                        tx_done <= 1'b1;       // завершення передачі
                        state <= IDLE;         // повернення у стан IDLE
                    end
                end
            endcase
        end
    end
endmodule

//---------------------------------------------------------------
// МОДУЛЬ: uart_rx
// Призначення : прийом послідовних бітів UART і відновлення байта
//---------------------------------------------------------------
module uart_rx (
    input  wire clk,           // системний такт
    input  wire reset,         // сигнал скидання
    input  wire tick,          // імпульс baud_tick від дільника
    input  wire rxd,           // вхідна лінія UART
    output reg  [7:0] data_out,// прийнятий байт даних
    output reg  data_valid     // сигнал готовності даних
);

    // --- стани FSM ---
    localparam IDLE  = 3'b000;  // очікування стартового біта
    localparam START = 3'b001;  // перевірка стартового біта
    localparam DATA  = 3'b010;  // прийом 8 бітів даних
    localparam STOP  = 3'b011;  // перевірка стоп-біта
    localparam READY = 3'b100;  // дані готові для зчитування

    reg [2:0] state;            // поточний стан автомата
    reg [7:0] shreg;            // зсувний регістр для прийнятих бітів
    reg [2:0] bit_cnt;          // лічильник кількості прийнятих бітів

    // Основний процес прийому UART
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            shreg <= 8'd0;
            bit_cnt <= 3'd0;
            data_out <= 8'd0;
            data_valid <= 1'b0;
        end else begin
            case (state)
                // Очікуємо падіння лінії RX (початок стартового біта)
                IDLE: begin
                    data_valid <= 1'b0;
                    if (!rxd) state <= START;
                end

                // Після одного такту baud_tick — переходимо до прийому даних
                START: begin
                    if (tick) state <= DATA;
                end

                // Приймаємо 8 бітів даних послідовно (LSB перший)
                DATA: begin
                    if (tick) begin
                        shreg <= {rxd, shreg[7:1]};   // зсув і запис нового біта
                        if (bit_cnt == 3'd7)
                            state <= STOP;            // усі біти прийнято
                        else
                            bit_cnt <= bit_cnt + 1'b1;
                    end
                end

                // Перевіряємо стоп-біт (має бути лог.1)
                STOP: begin
                    if (tick) state <= READY;
                end

                // Завершення прийому: фіксуємо байт і виставляємо прапорець
                READY: begin
                    data_out <= shreg;      // передаємо прийнятий байт
                    data_valid <= 1'b1;     // сигнал готовності
                    bit_cnt <= 3'd0;        // обнулення лічильника
                    state <= IDLE;          // повернення до очікування
                end
            endcase
        end
    end
endmodule

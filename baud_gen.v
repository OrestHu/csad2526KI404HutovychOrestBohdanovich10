//---------------------------------------------------------------
// МОДУЛЬ: baud_gen
// Призначення : створює імпульси baud_tick для UART
// CLK_FREQ  – частота системного такту (Гц)
// BAUD_RATE – швидкість UART (бод)
//---------------------------------------------------------------
module baud_gen #
(
    parameter CLK_FREQ = 50000000,  // частота системного такту, Гц
    parameter BAUD_RATE = 9600      // бажана швидкість UART, бод
)
(
    input  wire clk,     // системний тактовий сигнал
    input  wire reset,   // асинхронне скидання
    output reg  tick     // вихідний імпульс baud_tick
);

    // Обчислюємо кількість тактів між двома імпульсами baud_tick
    localparam integer DIVISOR = CLK_FREQ / BAUD_RATE;
    reg [31:0] counter; // лічильник тактів

    // Основний процес: підрахунок імпульсів системного такту
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            tick <= 0;
        end else begin
            if (counter >= DIVISOR - 1) begin
                counter <= 0;
                tick <= 1'b1;    // створюємо короткий імпульс baud_tick
            end else begin
                counter <= counter + 1;
                tick <= 1'b0;
            end
        end
    end
endmodule

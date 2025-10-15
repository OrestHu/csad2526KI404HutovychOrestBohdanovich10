//---------------------------------------------------------------
// МОДУЛЬ: baud_gen
// Призначення : створення імпульсу baud_tick для UART
// CLK_FREQ  – частота системного такту, Гц
// BAUD_RATE – швидкість UART, бод
//---------------------------------------------------------------
module baud_gen #
(
    parameter CLK_FREQ = 50_000_000,
    parameter BAUD_RATE = 9600
)
(
    input  wire clk,      // системний тактовий сигнал
    input  wire reset,    // асинхронне скидання
    output reg  tick      // вихідний імпульс baud_tick
);

    // Визначаємо, скільки тактів CLK відповідає одному біту UART
    localparam integer DIVISOR = CLK_FREQ / BAUD_RATE;
    reg [31:0] counter; // лічильник тактів

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            tick <= 0;
        end else if (counter == DIVISOR-1) begin
            counter <= 0;
            tick <= 1;        // короткий імпульс 1 такт
        end else begin
            counter <= counter + 1;
            tick <= 0;
        end
    end
endmodule
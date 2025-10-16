//---------------------------------------------------------------
// ??????: uart_rx
// ??????????? : ?????? ??????????? ????? UART ? ??????????? ?????
//---------------------------------------------------------------
module uart_rx (
    input  wire clk,           // ????????? ????
    input  wire reset,         // ????????
    input  wire tick,          // baud_tick
    input  wire rxd,           // ???? UART
    output reg  [7:0] data_out,// ????????? ????
    output reg  data_valid     // ????????? ??????????
);

    // --- ????? FSM ---
    localparam IDLE  = 3'b000;
    localparam START = 3'b001;
    localparam DATA  = 3'b010;
    localparam STOP  = 3'b011;
    localparam READY = 3'b100;

    reg [2:0] state;
    reg [7:0] shreg;
    reg [2:0] bit_cnt;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            shreg <= 8'd0;
            bit_cnt <= 3'd0;
            data_out <= 8'd0;
            data_valid <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    data_valid <= 1'b0;
                    if (!rxd) state <= START;  // ???????? ?????
                end

                START: begin
                    if (tick) state <= DATA;   // ??????? ??????????
                end

                DATA: begin
                    if (tick) begin
                        shreg <= {rxd, shreg[7:1]};
                        if (bit_cnt == 3'd7)
                            state <= STOP;
                        else
                            bit_cnt <= bit_cnt + 1'b1;
                    end
                end

                STOP: begin
                    if (tick) state <= READY;
                end

                READY: begin
                    data_out <= shreg;
                    data_valid <= 1'b1;
                    bit_cnt <= 3'd0;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule

//---------------------------------------------------------------
// ??????: uart_tx
// ??????????? : ?????????? ???????? ????? ????? UART-?????
//---------------------------------------------------------------
module uart_tx (
    input  wire clk,         // ????????? ????
    input  wire reset,       // ????????
    input  wire tick,        // ??????? baud_rate
    input  wire tx_start,    // ?????? ????????
    input  wire [7:0] data_in, // ???? ??? ????????
    output reg  txd,         // ????? UART
    output reg  tx_done      // ?????? ?????????? ????????
);

    // --- ????? FSM ---
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0] state;       // ???????? ????
    reg [7:0] shreg;       // ??????? ??????? ?????
    reg [2:0] bit_cnt;     // ????????? ????

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
                        shreg <= data_in;
                        bit_cnt <= 3'd0;
                        state <= START;
                    end
                end

                START: begin
                    txd <= 1'b0;          // ????????? ???
                    if (tick)
                        state <= DATA;
                end

                DATA: begin
                    if (tick) begin
                        txd <= shreg[0];  // ????????? LSB
                        shreg <= {1'b0, shreg[7:1]};
                        if (bit_cnt == 3'd7)
                            state <= STOP;
                        else
                            bit_cnt <= bit_cnt + 1'b1;
                    end
                end

                STOP: begin
                    txd <= 1'b1;          // ????-???
                    if (tick) begin
                        tx_done <= 1'b1;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule

`default_nettype none

module uart 
(
    parameter DELAY_FRAMES = 234 // (27Mhz clock divided by 234 gives us a standard 115200 baud rate)
)
(
    input clk,
    input uart_rx,
    output uart_tx,
    output reg [5:0] led,
    input btn1
);

    localparam  HALF_DELAY_WAIT = (DELAY_FRAMES / 2);

    reg [3:0] rxState = 0; // holds what state we are currently in
    reg [12:0] rxCounter = 0; // register that counts clock pulses 
    reg [2:0] rxBitNumber = 0; // keeps track of how many bits we have read so far 
    reg [7:0] dataIn; // stores the byte received 
    reg byteReady = 0; // flag register that tells us when we have finished reading a byte

    // our FSM will have consider the cases of rxState; relevant states are defined here
    localparam RX_STATE_IDLE = 0;
    localparam RX_STATE_START_BIT = 1;
    localparam RX_STATE_READ_WAIT = 2;
    localparam RX_STATE_READ = 3;
    localparam RX_STATE_STOP_BIT = 5;

    always @(posedge clk) begin 
        case (rxState)
            RX_STATE_IDLE: begin 
                if (uart_rx == 0) begin
                    rxState <= RX_STATE_START_BIT;
                    rxCounter <= 1;
                    rxBitNumber <= 0;
                    byteReady <= 0;
                end 
            end 
            RX_STATE_START_BIT: begin
                if (rxCounter == HALF_DELAY_WAIT) begin
                    rxState <= RX_STATE_READ_WAIT;
                    rxCounter <= 1
                end 
                else rxCounter <= rxCounter + 1;
            end 
            RX_STATE_READ_WAIT: begin
                rxCounter <= rxCounter + 1;
                if ((rxCounter + 1) == DELAY_FRAMES) begin
                    rxState <= RX_STATE_READ;
                end 
            end 
            RX_STATE_READ: begin
                rxCounter <= 1;
                dataIn <= {uart_rx, dataIn[7:1]}; // synthesized as a shift register - this is really efficient because it only uses bistables, often 0 LUTs
                rxBitNumber <= rxBitNumber + 1;
                if (rxBitNumber == 3'b111) rxState <= RX_STATE_STOP_BIT;
                else rxState <= RX_STATE_READ_WAIT;
            end 
            RX_STATE_STOP_BIT: begin
                rxCounter <= rxCounter + 1;
                if ((rxCounter + 1) == DELAY_FRAMES) begin
                    rxState <= RX_STATE_IDLE;
                    rxCounter <= 0;
                    byteReady <= 1;
                end
            end
        endcase 
    end 

    always @(posedge clk) begin
        if (byteReady) begin
            led <= ~dataIn[5:0];
        end
    end


endmodule


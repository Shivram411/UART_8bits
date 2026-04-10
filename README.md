# UART_8bits
Custom Verilog code for UART TX and RX at the 115200 baud frequency. 
Code is tuned for the ZYBO series board having a clock frequency of **125 Mhz** ( period of 8ns ).

## UART Transmitter
Takes in 8 bit data input from memory and once custom input start is high , the transmission process starts
The 125 Mhz to 115200Hz clock divider has been used hence the counter counting upto 1085 cycles per bit transmitted.
FSM holds 3 states: IDLE : waits for start bit
                    START : starts the 8 bit transmission. Cannot be stopped in the middle
                    STOP : Once 8 bit transmission is done , the final data pull up is done in this state and the FSM resets to IDLE.

##Board
Has been tested and verified on the ZYBO board.
Communication was done between this and the CPU using a TTL UART module connected to PC.




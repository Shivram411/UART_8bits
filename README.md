# UART_8bits
Custom Verilog code for UART TX and RX at the 115200 baud frequency. 
Code is tuned for the ZYBO series board having a clock frequency of **125 Mhz** ( period of 8ns ).

## UART Transmitter
Takes in 8 bit data input from memory and once custom input start is high , the transmission process starts
The 125 Mhz to 115200Hz clock divider has been used hence the counter counting upto 1085 cycles per bit transmitted.
FSM holds 3 states: IDLE : waits for start bit
                    START : starts the 8 bit transmission. Cannot be stopped in the middle
                    STOP : Once 8 bit transmission is done , the final data pull up is done in this state and the FSM resets to IDLE.


## UART Receiver
Takes in serial data via data_in every baud cycle and stores them in a 8bit register.
Also includes a 4 bit data_out variable which is tied to the led pins of the ZYBO board [LD0 - LD3]. Displays specific set of led sequence based on the input given which can be seen from the code.
Similar to the transmitter , the FSM here as well makes use of 3 states:
IDLE: Waits for data pull down after which goes to start.
START: Runs 8 bit baud counter and storing the received bit into a register.
STOP: After 8 bits are received , data is pulled high and the 1byte register is sent as output.

## UART_100Bytes_Memory file
Small mini project incorporating both UART Transmit and Receive and also 100 byte memory storage. 
Uses specific sequences for enabling storing , transmitting and type of transmission
Sequences include words: START , DYNAMIC , READ and COUNT
These words have to be passed bitwise via UART. 
Once START received , The next set of bytes are stored in the 100 byte memory. Overflow causes overwriting.
Once the memory is full , it automatically reverts to IDLE state. If the memory isn't full , sending the ENTER key equivalent ( <CR> <LF> ) will send it back to IDLE state.
COUNT tells you the amount of space that is occupied in the memory.
READ basically transmits back whatever is stored in the memory. Note that it doesn't erase the contents of the memory.
DYNAMIC is a slightly modified version of READ where in you will have to type in a ascii equivalent of a any number between 0 to 99 and it will fetch you that many bytes from the right.

It is implemented again on the ZYBO board.
The code has basic flaws which doesn't cause any errors but can be fixed if time permits. For example: I have incorporated only capital letters for the specific sequence , small alphabets can be added.


## Board & Software
Has been tested and verified on the ZYBO board using Xilinx Vivado
Communication was done between the board and the CPU using a TTL UART module.
Code is fully synthesizeable.




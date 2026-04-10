module UART_TX( input clk , rst , start,
                input [7:0] data_in,
                output reg data_out, 
                output reg tx_valid );

parameter
    IDLE  =  2'b00,
    START =  2'b01,
    STOP  =  2'b10;
reg [1:0] state;
reg [3:0] data_counter;
reg [7:0] input_data;
reg [11:0] baud_counter; 

always@(posedge clk)
begin
    if(~rst)
    begin
        state           <= IDLE;
        data_counter    <= 0;
        input_data      <= data_in;     
        baud_counter    <= 0;
        data_out <= 1;
        tx_valid <= 0;
    end
    else
    begin
        case(state)
            IDLE:
            begin
                tx_valid <= 0;
                if(start)
                begin                 
                        data_out <= 1;
                        input_data      <= data_in ;
                        state <= START;
                    end
                end     
            START:
            begin
                if(data_counter == 0)
                begin
                    if(baud_counter  < 11'd1084)
                    begin
                        data_out <= 0;
                        baud_counter <= baud_counter + 1;
                    end
                    else
                    begin
                        baud_counter <= 0;
                        data_counter <= data_counter + 1;
                    end
                end
                else if(data_counter < 4'd9)     
                begin
                    if(baud_counter  < 11'd1084)
                    begin
                            data_out <= input_data[0];
                            baud_counter <= baud_counter + 1;
                    end
                    else if(baud_counter == 11'd1084)
                    begin
                            input_data <= input_data >> 1;
                            data_counter <= data_counter + 1;
                            baud_counter <= 0;
                    end
                end
                else
                begin
                        data_counter <= 0;
                        state <= STOP;
                end
                    
            end
            
            STOP:
            begin
                if(baud_counter < 11'd1084 )
                begin               
                    data_out <= 1;
                    baud_counter <= baud_counter + 1;
                end
                else
                begin
                    tx_valid <= 1;
                    baud_counter <= 0;
                    state <= IDLE;
                end
            end
       endcase
   end
end

endmodule

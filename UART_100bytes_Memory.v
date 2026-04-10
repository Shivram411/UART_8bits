`timescale 1ns / 1ps
module UART_100bytes (  input clk, rst , 
			input datain_rx, 
		    output dataout_tx,
			output reg [3:0]led_out);



parameter 
	RX_IDLE 	= 5'b00000,
	RX_S    	= 5'b00001,
	RX_T    	= 5'b00010,
	RX_A		= 5'b00011,
	RX_R   		= 5'b00100,
	RX_START	= 5'b00101,
	RX_O		= 5'b00110,
	RX_STOP		= 5'b00111,
	RX_E		= 5'b01000,
	RX_READ     = 5'b01001,
	RX_C		= 5'b01010,
	RX_U		= 5'b01011,
	RX_N		= 5'b01100,
	RX_COUNT	= 5'b01101,
	RX_D		= 5'b01110,
	RX_Y		= 5'b01111,
	RX_M		= 5'b10000,
	RX_I		= 5'b10001,
	RX_DYNAMIC	= 5'b10010;

reg  [4:0]   state;
reg  [6:0]   memory_counter;
reg         start_TX;
wire [7:0]  dataout_rx;
wire        rx_valid , tx_valid;
reg  [7:0]  memory [0:99];
reg  [7:0]  message_out;
reg  [7:0]  dynamic_count;
reg         dynamic_ready;
wire [3:0]  ledout1;
reg  [7:0]  number_memoryitems;
reg  [1:0]  d_count;


UART_RX receiving (clk , rst , datain_rx , ledout1     , dataout_rx , rx_valid );
UART_TX sending   (clk , rst , start_TX  , message_out , dataout_tx , tx_valid ); 

always@(posedge clk)
begin
	if(~rst)
	begin
		state                 <= 	RX_IDLE;
		memory_counter        <= 	0;
		start_TX              <= 	0;
		message_out           <=    0;
		dynamic_count         <=    0;
		d_count               <=    0;
		number_memoryitems    <=    0;
		dynamic_ready         <=    0;
	end
	else
	begin
		case(state)
                RX_IDLE:	
                begin
                    memory_counter    <= 	0;
                    led_out           <=    4'b1001;
                    dynamic_ready     <=    0;
                    dynamic_count     <=    0;
                    if(rx_valid)
                    begin
                        if(dataout_rx == 8'b0101_0011)        // S
                        begin
                            state <= RX_S;
                        end
                        
                        else if(dataout_rx == 8'b0101_0010)   // R
                        begin
                            state <= RX_R;
                        end
                        
                        else if(dataout_rx == 8'b0100_0011)   // C
                        begin
                            state <= RX_C;
                        end
                    
                        else if(dataout_rx == 8'b0100_0100)   // D
                        begin
                            state <= RX_D;
                        end
                        else
                        begin
                            state <= RX_IDLE;
                        end
                    end
                end
                
                RX_S:
                begin
                    led_out     <= 4'b0010;
                    if(rx_valid) 
                    begin
                        if(dataout_rx == 8'b0101_0100 )          //T
                        begin
                            state <= RX_T;
                        end
                        else
                        begin
                            state <= RX_IDLE;
                        end
                    end
                    
                end
                
                RX_T:
                begin
                    led_out <= 4'b0011;
                    if(rx_valid)
                    begin
                        if(dataout_rx == 8'b0100_0001)         //A
                        begin
                            state <= RX_A;
                        end
                        else if(dataout_rx == 8'b0100_1111)    //O
                        begin
                            state <= RX_O;
                        end
                        else
                        begin
                            state <= RX_IDLE ;
                        end
                    end
                end
    
                RX_A:
                begin
                    led_out <= 4'b0100;
                    if(rx_valid)
                    begin
                        if(dataout_rx == 8'b0101_0010)          //R
                        begin
                            state <= RX_R;
                        end
                        
                        else if(dataout_rx == 8'b0100_0100)    //D
                        begin
                            state <= RX_READ;
                        end
                        
                        else if(dataout_rx == 8'b0100_1101)    //M
                        begin
                            state <= RX_M;
                        end
                        else
                        begin
                            state <= RX_IDLE;
                        end
                    end                      
                end
                
                RX_R:
                begin
                    led_out <= 4'b0101;
                    if(rx_valid)
                    begin
                        if(dataout_rx == 8'b0101_0100 && rx_valid)         //T
                        begin
                            state <= RX_START;
                        end
                        
                        else if(dataout_rx == 8'b0100_0101)    //E
                        begin
                            led_out <= 4'b0110;
                            state <= RX_E; 
                        end
                        else
                        begin
                            state <= RX_IDLE;
                        end
                    end
                end
            
                RX_D:
                begin
                    if(rx_valid)
                    begin
                    
                        if(dataout_rx == 8'b0101_1001)         //Y
                        begin
                            state <= RX_Y;
                        end
                        else
                        begin
                            state <= RX_IDLE;
                        end
                    end
                end
                
                RX_Y:
                begin
                    if(rx_valid)
                    begin
                        if(dataout_rx == 8'b0100_1110)        //N
                        begin
                            state <= RX_N;
                        end
                        else
                        begin
                            state <= RX_IDLE;
                        end
                    end
                end
                
                RX_N:
                begin
                    if(rx_valid)
                    begin
                        if(dataout_rx == 8'b0100_0001)        //A
                        begin
                            state <= RX_A;
                        end
                        
                        else if(dataout_rx == 8'b0101_0100)   //T
                        begin
                            state <= RX_COUNT;
                        end
                        else
                        begin
                            state <= RX_IDLE;
                        end
                    end
                end
    
                RX_M:
                begin
                    if(rx_valid)
                    begin
                        if(dataout_rx == 8'b0100_1001)        //I
                        begin
                            state <= RX_I;
                        end
                        else
                        begin
                            state <= RX_IDLE;
                        end
                    end
                end
                
                RX_C:
                begin
                    if(rx_valid)
                    begin
                       
                        if(dataout_rx == 8'b0100_1111)        //O
                        begin
                            state <= RX_O;
                        end
                        else
                        begin
                            state <= RX_IDLE;
                        end
                    end
                end
                        
        
                RX_I: 
                begin  
                    if(rx_valid)
                    begin 
                        if(dataout_rx == 8'b0100_0011 && rx_valid)       //C
                        begin
                            state <= RX_DYNAMIC;
                        end
                        else
                        begin
                            state <= RX_IDLE;
                        end
                    end
                end
    
                RX_O:
                begin
                    if(rx_valid)
                    begin                   
                        if(dataout_rx == 8'b0101_0101)       //U
                        begin
                            state <= RX_U;
                        end
        
                        else if(dataout_rx == 8'b0101_0000)
                        begin
                            state <= RX_STOP;
                        end
                        else
                        begin
                            state <= RX_IDLE;
                        end
                    end
                end
        
                RX_U:
                begin
                    if(rx_valid)
                    begin
                        if(dataout_rx == 8'b0100_1110)       //N
                        begin
                            state <= RX_N;
                        end
                        else
                        begin
                            state <= RX_IDLE;
                        end
                    end
                end
                
                RX_E:
                begin
                    if(rx_valid)
                    begin
                        if(dataout_rx == 8'b0100_0001) //A
                        begin
                            state <= RX_A ;
                        end
                        else
                        begin
                            state <= RX_IDLE;
                        end
                    end
                    
                end
    
    
                RX_START:
                begin
                    //led_out <= 4'b1111;
                    if(memory_counter == 7'd0 && ~dynamic_ready && rx_valid )
                    begin
                        memory_counter         <= memory_counter + 1;
                        memory[memory_counter] <= dataout_rx;
                    end
                     
                    else if(memory_counter < 7'd100 && rx_valid && ~dynamic_ready && (dataout_rx != 8'b0000_1101 && dataout_rx != 8'b0000_1010))
                    begin
                        memory[memory_counter] <= dataout_rx;
                        memory_counter         <= memory_counter + 1;
                    end
                         		             
                    else if(dataout_rx == 8'b0000_1101 && ~dynamic_ready )  // [CR]
                    begin
                        state <= RX_START;
                    end
                     
                    else if(dataout_rx == 8'b0000_1010 && ~dynamic_ready)  // [LF]
                    begin
                         state <= RX_STOP;
                         if(number_memoryitems != 7'd99)
                            number_memoryitems <= memory_counter ;
                    end
                    
                    else if(memory_counter == 7'd100)
                    begin
                         memory_counter <= 0;
                         number_memoryitems <= 7'd99;
                         state          <= RX_IDLE;
                    end
                    
                    else if(dynamic_ready)
                    begin
                        if(d_count == 2'd0 && rx_valid)
                        begin 
                            led_out <= 4'b0001;
                            dynamic_count <= dataout_rx;
                            d_count <= d_count + 1;
                            state <= RX_READ;
                            memory_counter <= 0;
    
                        end                
		          end
              end
		        
		        RX_COUNT:
		        begin
		              led_out <= 4'b1010;
		              if(~start_TX)
		              begin
		                  start_TX <= 1;
		                  message_out <= number_memoryitems;
		                  state <= RX_COUNT;
		              end

		              else if(start_TX)
		              begin
		                  start_TX <= 0;
		                  message_out <= number_memoryitems;
		                  state    <= RX_IDLE;
		              end
		       end
		       
		       RX_READ:
		       begin  
		              start_TX <= 0; 
		              led_out <= 4'b1011;
		              if(memory_counter == 7'd0 && ~dynamic_ready)
		              begin
		                  start_TX        <= 1;
		                  memory_counter  <= memory_counter + 1;
		                  
		                  message_out     <= memory[0];
		             end 
		             else if (memory_counter < number_memoryitems  && tx_valid && ~dynamic_ready)
		             begin
		                  start_TX       <= 1;
		                  memory_counter <= memory_counter + 1;
		                  message_out    <= memory[memory_counter];                
		             end
		             
		             else if (memory_counter == number_memoryitems && ~dynamic_ready )
		             begin
		                  start_TX    <= 0;
		                  state       <= RX_IDLE;
		             end
		             
		             else if (dynamic_ready)
		             begin
		              
		                  led_out <= 4'b1110;
		                  start_TX  <= 0;
		                  if(memory_counter == 7'd0) 
		                  begin
		                      
                              start_TX <= 1;
                              memory_counter <= number_memoryitems - dynamic_count + 1 ;
                              message_out <= /*dynamic_count;*/ memory[number_memoryitems - dynamic_count];
                          end
                          
                          else if(memory_counter < number_memoryitems  && tx_valid)
                          begin
                              start_TX <= 1;
                              memory_counter <= memory_counter + 1;
                              message_out <= /*dynamic_count;*/  memory[memory_counter];
                          end
                          
                          else if (memory_counter == number_memoryitems && tx_valid )
                          begin 
                                start_TX <= 0;
                                memory_counter <= 0;
                                dynamic_ready <= 0;
                                dynamic_count <= 0;
                                state <= RX_IDLE;
                                d_count <= 0;
                          end
                     end
                                                                             
               end
               
               RX_STOP:
               begin
                    state <= RX_IDLE;
               end
               
               RX_DYNAMIC:
               begin
                    dynamic_ready <= 1;
                    state <= RX_START;
               end
                                    	                  
		   endcase
		   end
		   end
		   endmodule	
			

`timescale 1ns / 1ps // Defines this module's simulation time unit (1 ns) and time precision unit (1 ps)

module temp_sensor_reader (
    input logic clk,
    input logic rst,
    output logic signed [11:0] temperature,
    output logic valid,
    output logic i2c_scl,
    inout wire i2c_sda
);
    
    logic [11:0] counter;
    logic [7:0] lfsr;
    
    assign i2c_scl = 1'b1;
    assign i2c_sda = 1'bz;
    
    always_ff@(posedge(clk), posedge(rst)) begin
       if(rst) begin                         
          counter <= 0;
          temperature <= 12'sd20;
          valid <= 0;
          lfsr <= 8'hA5;
       end
       else begin
          counter <= counter + 1;
          valid <= 0; 
    
          if(counter == 1_000_000) begin
             counter <= 0;
                
             // 8-bit LFSR: x^8 + x^6 + x^5 + x^4 + 1
             lfsr <= {lfsr[6:0], lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3]};
                
             // Small signed variation: -2 to +1
             temperature <= temperature + $signed({1'b0, lfsr[1:0]}) - 12'sd2;
               
             valid <= 1;
          end
       end
    end
         
endmodule
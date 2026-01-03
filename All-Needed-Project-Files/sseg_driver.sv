`timescale 1ns / 1ps // Defines this module's simulation time unit (1 ns) and time precision unit (1 ps)

module sseg_driver (
    input logic clk,
    input logic rst,
    input logic [15:0] value,
    input logic moving,
    output logic [6:0] seg,
    output logic [3:0] an
);
    
    logic [23:0] flash_counter;
    logic flash_state;
    
    // Flash counter (~0.1s period at 100MHz)
    always_ff@(posedge(clk), posedge(rst)) begin
       if(rst) begin                         
          flash_counter <= 0;
          flash_state <= 0;
       end
       else if(moving) begin
          flash_counter <= flash_counter + 1;
          if(flash_counter == 5_000_000) begin
             flash_counter <= 0;
             flash_state <= ~flash_state;
          end   
       end
       else begin
          flash_counter <= 0;
          flash_state <= 1; // steady ON when still
       end
    end
    
    // Seven-segment display
    always_ff@(posedge(clk), posedge(rst)) begin
       if(rst) begin                         
          an <= 4'b1110;
          seg <= 7'b1000000;
       end
       else begin
          an <= 4'b1110;
          if(moving) begin
             seg <= flash_state ? 7'b1111001 : 7'b0000000;
          end
          else begin
             seg <= 7'b1000000; // 0 when still
          end
       end
    end
    
endmodule
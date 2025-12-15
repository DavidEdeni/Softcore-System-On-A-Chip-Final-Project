`timescale 1ns / 1ps // Defines this module's simulation time unit (1 ns) and time precision unit (1 ps)

module uart_tx2 #(
   parameter CLK_FREQ = 100_000_000, 
   parameter BAUD     = 115200
)(
    input logic clk,
    input logic rst,
    input logic moving,
    output logic tx,
    output logic busy
);
    
    localparam DIV = CLK_FREQ / BAUD;
    logic [15:0] div_count;
    logic [3:0] bit_count;
    logic [9:0] shift;
    
    logic send_pulse;
    logic [23:0] send_counter;
    
    // Generate a send pulse periodically (~0.1s)
    always_ff@(posedge(clk), posedge(rst)) begin
       if(rst) begin                         
          send_counter <= 0;
          send_pulse <= 0;
       end
       else begin
          send_counter <= send_counter + 1;
          if(send_counter >= 10_000_000) begin // `0.1s
             send_counter <= 0;
             send_pulse <= 1;
          end 
          else begin
             send_pulse <= 0;
          end
       end
    end
       
    // UART transmission
    always_ff@(posedge(clk), posedge(rst)) begin
       if(rst) begin                         
          tx <= 1'b1;
          busy <= 0;
          div_count <= 0;
          bit_count <= 0;
          shift <= 10'b1111111111;
       end
       else if(send_pulse && !busy) begin
          shift <= {1'b1, (moving ? "M" : "S"), 1'b0}; // start/stop + data
          busy <= 1;
          div_count <= 0;
          bit_count <= 0;
       end
       else if(busy) begin
          if(div_count == DIV-1) begin
             div_count <= 0;
             tx <= shift[0];
             shift <= {1'b1, shift[9:1]};
             bit_count <= bit_count + 1;
             if(bit_count == 9)
                busy <= 0;
          end
          else
             div_count <= div_count + 1;
       end
    end
    
endmodule
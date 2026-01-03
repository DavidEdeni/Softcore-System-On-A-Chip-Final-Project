`timescale 1ns / 1ps // Defines this module's simulation time unit (1 ns) and time precision unit (1 ps)

module motion_classifier (
    input logic clk,
    input logic rst,
    input logic sample_valid,
    input logic signed [11:0] value,
    output logic moving
);
    
    logic signed [11:0] last;
    logic signed [12:0] diff;
    
    always_ff@(posedge(clk), posedge(rst)) begin
       if(rst) begin                         
          last <= 12'sd20;
          moving <= 0;
       end
       else if(sample_valid) begin
          diff <= value - last;
              
          if(diff < 0)
             diff <= -diff;
                
             moving <= (diff > 13'sd2);
             last <= value;
       end
    end
         
endmodule
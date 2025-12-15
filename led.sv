`timescale 1ns / 1ps // Defines this module's simulation time unit (1 ns) and time precision unit (1 ps)

module led( // Defines an LED control module for driving a single LED on a Nexys4 DDR™ FPGA Board
    input logic clk, // Input clock signal (usually 100 MHz for FPGAs). This signal provides timing and synchronization for digital circuits.
    input logic reset, // Active-high reset input signal. This signal resets a digital circuit to a known starting state. reset = 1 → reset is on (the circuit resets). reset = 0 → reset is off (the circuit runs normally).
    input logic [15:0] led_blink_rate_ms, // 16-bit LED blink rate input control signal that specifies the LED blink rate period in milliseconds. This value defines how long the LED will stay in one state before toggling. A value of 0 disables blinking and forces the LED off.
    output logic LED // Output control signal that drives a physical LED on a Nexys4 DDR™ FPGA Board
    );

    logic [31:0] count; // Declare a 32-bit register for a current counter value (count) 
    logic [31:0] clock_cycle_rate; // Declare a 32-bit register that stores the number of clock cycles required for the desired blink interval (clock_cycle_rate) 

    assign clock_cycle_rate = led_blink_rate_ms * (CLK100MHZ * 1000); // Converts the LED blink rate from milliseconds into clock cycles based on the 100 MHZ system clock.
    
    always_ff @(posedge clk, posedge reset) begin // Sequential logic block that runs on a rising edge of a clock (when clock goes from 0 → 1) or when reset goes high (when reset goes from 0 → 1)
       if(reset) begin  // If reset is active (reset = 1)
          count <= 0; // Reset counter to zero (non-blocking [<=] used here because this is sequential logic, not combinational logic)
          LED <= 0;   // Turn/drive the LED off to ensure a known startup state (non-blocking [<=] used here because this is sequential logic, not combinational logic)
       end
       else begin // If reset is not active (reset = 0)
          if(led_blink_rate_ms == 0) begin // If the LED blink rate is zero
             LED <= 0;   // Turn/drive the LED off to ensure a known startup state (non-blocking [<=] used here because this is sequential logic, not combinational logic)
             count <= 0; // Reset counter to zero (non-blocking [<=] used here because this is sequential logic, not combinational logic)
          end
          else if(count >=  clock_cycle_rate - 1) begin // If the counter has reached the total number of clock cycles required for the programmed blink interval. When this condition is true, the specified time delay has fully elapsed, meaning it is time to change the LED state.
             LED <= ~LED; // Toggle the LED state (non-blocking [<=] used here because this is sequential logic, not combinational logic)
             count <= 0;  // Reset counter to zero (non-blocking [<=] used here because this is sequential logic, not combinational logic)
          end
          else begin // If the blink interval has not yet elapsed, the counter continues counting clock cycles until it reaches the required value that corresponds to the selected blink period.
              count <= count + 1; // Increment counter value up by 1 on each clock cycle (non-blocking [<=] used here because this is sequential logic, not combinational logic)
          end
       end
    end

endmodule // End of module definition
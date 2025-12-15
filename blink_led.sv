`timescale 1ns / 1ps // Defines this module's simulation time unit (1 ns) and time precision unit (1 ps)

module blink_led#(parameter N = 4)( // Defines the top-level module that controls multiple LED blink rates via memory-mapped registers on a Nexys4 DDR™ FPGA Board
    input logic clk, // Input clock signal (usually 100 MHz for FPGAs). This signal provides timing and synchronization for digital circuits.
    input logic reset, // Active-high reset input signal. This signal resets a digital circuit to a known starting state. reset = 1 → reset is on (the circuit resets). reset = 0 → reset is off (the circuit runs normally).
    input logic chip_select, // Active-high chip select input control signal that enables this peripheral to respond to read and write transactions on the system memory-mapped bus, all other bus activity is ignored when deasserted.
    input logic read_enable, // Read enable input control signal for register access. This signal indicates whether a valid read transaction has occured, when this signal is asserted, the addressed register's contents are driven onto the read data bus, when deasserted no read operation occurs.
    input logic write_enable, // Write enable input control signal for register access. This signal indicates whether a valid write transaction has occured, when this signal is asserted, the data on the write data bus is written into the addressed register, when this signal is deasserted no write operation occurs.
    input logic [4:0] address_bus, // 5-bit address bus input control signal used to select internal memory-mapped registers within the module. Each unique address corresponds to a specific register or control function, allowing the CPU or external controller to read from or write to that register. Only the lower bits may be used depending on the number of registers implemented.  
    input logic [31:0] write_data, // 32-bit write data bus for writing values to the LED blink rate registers
    output logic [31:0] read_data, // 32-bit read data bus for reading values from the LED blink rate registers
    output logic [N-1:0] LED // 4-bit output control vector that drives the physical LEDs on a Nexys4 DDR™ FPGA Board
    );

    logic [15:0] led_blink_rate_register [3:0]; // Declare four (3:0) 16-bit registers storing LED blink rates
    logic internal_write_enable; // Internal write-enable control signal generated from chip select and write enable input control signal
    
    always_ff @(posedge clk, posedge reset) begin // Sequential logic block that runs on a rising edge of a clock (when clock goes from 0 → 1) or when reset goes high (when reset goes from 0 → 1)
       if(reset) begin  // If reset is active (reset = 1)
          led_blink_rate_register[0] <= 16'd0; // Clear the LED blink rate register for LED 0
          led_blink_rate_register[1] <= 16'd0; // Clear the LED blink rate register for LED 1
          led_blink_rate_register[2] <= 16'd0; // Clear the LED blink rate register for LED 2
          led_blink_rate_register[3] <= 16'd0; // Clear the LED blink rate register for LED 3
       end
       else if(internal_write_enable) begin // If a valid write transaction is requested 
          case(address_bus) // Decode the address bus to select which register to write to
             5'd0: led_blink_rate_register[0] <= write_data; // Write the blink rate for LED 0
             5'd1: led_blink_rate_register[1] <= write_data; // Write the blink rate for LED 1
             5'd2: led_blink_rate_register[2] <= write_data; // Write the blink rate for LED 2
             5'd3: led_blink_rate_register[3] <= write_data; // Write the blink rate for LED 3
          endcase
       end
    end
    
    assign internal_write_enable = chip_select && write_enable; // Assert the internal write enable signal only when chip/peripheral is selected and write enable is active
    
    always_comb begin // Combinational logic block for read transactions
       case(address_bus[2:1]) // Use address bus bits 2 and 1 to select which LED blink rate register to read from
          2'd0: read_data <= {16'd0, led_blink_rate_register[0]}; // Read the LED blink rate for LED 0
          2'd1: read_data <= {16'd0, led_blink_rate_register[1]}; // Read the LED blink rate for LED 1
          2'd2: read_data <= {16'd0, led_blink_rate_register[2]}; // Read the LED blink rate for LED 2
          2'd3: read_data <= {16'd0, led_blink_rate_register[3]}; // Read the LED blink rate for LED 3
          default: read_data = 32'd0; // If none of the specified register addresses match, return a zeroed 32-bit value to indicate an invalid or unused address. This prevents accidental propogation of undefined or stale data onto the read data bus.
       endcase
    end
    
    led led1( // Instantiates the first LED controller module for the Nexys4 DDR™ FPGA Board
       .clk(clk), // Connect the system clock signal to the LED controller
       .reset(reset), // Connect the reset signal to the LED controller
       .led_blink_rate_ms(led_blink_rate_register[0]), // Provide a LED blink rate for LED 0 from the LED blink rate register
       .LED(LED[0]) // Drive physical LED 0 (first LED in our configuration)
    );
    
    led led2( // Instantiates the second LED controller module for the Nexys4 DDR™ FPGA Board
       .clk(clk), // Connect the system clock to the LED controller
       .reset(reset), // Connect the reset signal to the LED controller
       .led_blink_rate_ms(led_blink_rate_register[1]), // Provide a LED blink rate for LED 1 from the LED blink rate register
       .LED(LED[1]) // Drive physical LED 1 (second LED in our configuration)
    );
    
    led led3( // Instantiates the third LED controller module for the Nexys4 DDR™ FPGA Board
       .clk(clk), // Connect the system clock signal to the LED controller
       .reset(reset), // Connect the reset signal to the LED controller
       .led_blink_rate_ms(led_blink_rate_register[2]), // Provide a LED blink rate for LED 2 from the LED blink rate register
       .LED(LED[2]) // Drive physical LED 2 (third LED in our configuration)
    );
    
    led led4( // Instantiates the fourth LED controller module for the Nexys4 DDR™ FPGA Board
       .clk(clk), // Connect the system clock signal to the LED controller
       .reset(reset), // Connect the reset signal to the LED controller
       .led_blink_rate_ms(led_blink_rate_register[3]), // Provide a LED blink rate for LED 3 from the LED blink rate register
       .LED(LED[3]) // Drive physical LED 3 (fourth LED in our configuration)
    );
    
endmodule // End of module definition
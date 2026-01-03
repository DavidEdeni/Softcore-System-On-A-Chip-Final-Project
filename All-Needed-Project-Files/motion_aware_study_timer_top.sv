`timescale 1ns / 1ps // Defines this module's simulation time unit (1 ns) and time precision unit (1 ps)

module motion_aware_study_timer_top #(parameter BRG_BASE = 32'hc000_0000)
    (
    input logic clk,
    input logic rst,
    output logic [6:0] seg,
    output logic [3:0] an,
    output logic uart_tx_o,
    output logic i2c_scl,
    inout wire  i2c_sda
);

    logic signed [11:0] temperature;
    logic sample_valid;
    logic moving;

    // Temperature sensor reader (simulated with proxy)
    temp_sensor_reader temp (
       .clk(clk),
       .rst(rst),
       .temperature(temperature),
       .valid(sample_valid),
       .i2c_scl(i2c_scl),
       .i2c_sda(i2c_sda)
    );

    // Motion classifier using temperature changes
    motion_classifier mc (
       .clk(clk),
       .rst(rst),
       .sample_valid(sample_valid),
       .value(temperature),
       .moving(moving)
    );

    // Seven-segment display driver with flashing when moving
    sseg_driver sseg (
        .clk(clk),
        .rst(rst),
        .value(moving ? 16'd1 : 16'd0),
        .moving(moving),
        .seg(seg),
        .an(an)
    );

    // UART output printing M/S repeatedly
    uart_tx2 uart (
       .clk(clk),
       .rst(rst),
       .moving(moving),
       .tx(uart_tx_o),
       .busy()
    );	         

endmodule
`timescale 1ns / 1ps
`default_nettype none
module detect_to_theta #(
    parameter THETA_RES=27
)
(
    input wire ir_tripped,
    input wire clk_in,
    input wire rst_in,
    output logic [THETA_RES-1:0] theta, // where we currently are in the rotation
    output logic period_ready, // single-cycle high for when new period is ready to be sent
    output logic [THETA_RES-1:0] period // counter since last time IR tripped
);
    // inspired by evt_counter

    // THETA_RES thought process:
    //  * 100MHz clock => 10ns periods (make sure this is the case!! not like 12MHz or smth)
    //  * Suppose we are rotating (conservatively) at 300RPM => 5Hz => 0.2s per revolution
    //  * Highest theta is 0.2s / 10ns = 20M
    //  * # of bits = ceil(log2(20M)) = 25 bits (minimum)

    // EXTRA CONSIDERATIONS for future:
    //  * Debouncing?
    //  * Is the sensor synchronized with the FPGA clock?
    //  * period lags behind theta by ~one revolution

    logic old_ir_tripped;

    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            theta <= 0;
            period_ready <= 0;
            period <= 0;
            old_ir_tripped <= 0;
        end else begin
            if (ir_tripped & ~old_ir_tripped) begin // ir_tripped went from low to high
                period_ready <= 1;
                period <= theta;
                theta <= 0;
            end else begin
                theta <= theta + 1;
            end
            if (period_ready) begin
                // single cycle high for sending period
                period_ready <= 0;
            end
            old_ir_tripped <= ir_tripped;
        end
    end
endmodule
`default_nettype none
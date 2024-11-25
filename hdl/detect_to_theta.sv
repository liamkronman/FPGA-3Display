module detect_to_theta #(
    parameter THETA_RES=27,
)
(
    input wire ir_tripped,
    input wire clk_in,
    input wire rst_in,
    output logic [THETA_RES-1:0] theta, // where we currently are in the rotation
    output logic period_ready, // single-cycle high for when new period is ready to be sent
    output logic [THETA_RES-1:0] period // counter since last time 
);
    // inspired by evt_counter

    // THETA_RES thought process:
    //  * 100MHz clock => 10ns periods
    //  * Suppose we are rotating (conservatively) at 300RPM => 5Hz => 0.2s per revolution
    //  * Highest theta is 0.2s / 10ns = 20M
    //  * # of bits = ceil(log2(20M)) = 25 bits (minimum)

    // EXTRA CONSIDERATIONS for future:
    //  * Debouncing?
    //  * Is the sensor synchronized with the FPGA clock?
    //  * period lags behind theta by one revolution

    // COMMENTED FOR TESTING ir_led_control (BECAUSE UNFINISHED)
    // always_ff @(posedge clk_in) begin
    //     if (rst_in) begin
    //         theta <= 0;
    //         period_ready <= 0;
    //         period <= 0;
    //     end else begin
    //         if (ir_tripped) begin
    //             period_ready <= 1;
    //         end else begin
    //             period_ready <= 0;
    //             period <= period + 1;
    //             theta <= theta + 1;
    //         end
    //         if (period_ready) begin
    //             // single cycle high for sending period
    //             period_ready <= 0;
    //             theta 
    //         end
    //     end
    // end
endmodule
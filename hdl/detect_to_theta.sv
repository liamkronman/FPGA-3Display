`timescale 1ns / 1ps
`default_nettype none
module detect_to_theta #(
    parameter THETA_RES=32,
    parameter ROTATIONAL_RES=1024
)
(
    input wire ir_tripped,
    input wire clk_in,
    input wire rst_in,
    output logic [$clog2(ROTATIONAL_RES)-1:0] dtheta // discretized theta (where we currently are in the rotation)
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

    logic [THETA_RES-1:0] theta; // this is an absolute theta. used during the swap => period.
    logic [THETA_RES-1:0] period; // counter since last time IR tripped
    logic [THETA_RES-1:0] cp_theta; // count per theta (period >> log2(ROTATIONAL_RES))
    logic [THETA_RES-1:0] angle_counter; // within each angle, this counter increases, and compared to cp_theta-1 to determine when dtheta increments.

    // Consider: a smoother period (like having speriod which is the average over the past 8 revolutions?)

    logic old_ir_tripped;

    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            theta <= 0;
            period <= $clog2(THETA_RES);
            old_ir_tripped <= 0;
            cp_theta <= ROTATIONAL_RES;
            angle_counter <= 0;
            dtheta <= 0;
        end else begin
            if (ir_tripped & ~old_ir_tripped) begin // ir_tripped went from low to high
                period <= theta;
                theta <= 0;
                cp_theta <= (theta >> $clog2(ROTATIONAL_RES));
                angle_counter <= 0;
            end else begin
                theta <= theta + 1;
                if (angle_counter == cp_theta-1) begin
                    if (dtheta == ROTATIONAL_RES-1) begin
                        dtheta <= 0;
                    end else begin
                        dtheta <= dtheta + 1;
                    end
                    angle_counter <= 0;
                end else begin
                    angle_counter <= angle_counter + 1;
                end
            end
            old_ir_tripped <= ir_tripped;
        end
    end
endmodule
`default_nettype none
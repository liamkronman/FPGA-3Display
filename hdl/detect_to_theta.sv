module detect_to_theta #(
    parameter THETA_RES=27,
)
(
    input wire ir_tripped,
    input wire clk_in,
    input wire rst_in,
    output logic [THETA_RES-1:0] theta,
    output logic theta_ready,
    
);
    // inspired by evt_counter

    // THETA_RES thought process:
    //  * 100MHz clock => 10ns periods
    //  * Suppose we are rotating (conservatively) at 300RPM => 5Hz => 0.2s per revolution
    //  * Highest theta is 0.2s / 10ns = 20M
    //  * # of bits = ceil(log2(20M)) = 25 bits

    // EXTRA CONSIDERATIONS for future:
    //  * Debouncing?
    //  * Is the sensor synchronized with the FPGA clock?

    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            theta <= 0;
            theta_ready <= 0;
        end else begin
            if (ir_tripped) begin
                theta_ready <= 1;
                theta <= 0;
            end else begin
                theta_ready <= 0;
                theta <= theta + 1;
            end
        end
    end
endmodule
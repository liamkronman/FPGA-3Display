// this module takes the outputs of detect_to_theta and converts a dynamic theta (wrt to a changing period) to a theta that is in [0, ROTATIONAL_RES).

// this module is DEPRECATED...

// `default_nettype none
// module discrete_theta (
//     parameter ROTATIONAL_RES=256,
//     parameter THETA_RES=27
// )
// (
//     input wire rst_in,
//     input wire [THETA_RES-1:0] theta,
//     input wire period_ready,
//     input wire [THETA_RES-1:0] period,
//     output logic [$clog2(ROTATIONAL_RES)-1:0] dtheta // discretized theta
// );
//     logic [THETA_RES-1:0] curr_period;
//     if (rst_in) begin
//         curr_period <= ROTATIONAL_RES;
//         dtheta <= 0;
//     end else begin
//         // substitute in the period whenever period_ready (single-cycle) goes high.
//         if (period_ready) begin
//             curr_period <= period; // HUGE PROBLEM (potentially) is that curr_period is undefined at first
//         end
//         if (curr_period != 0) begin
//             dtheta <= (theta * ROTATIONAL_RES) / curr_period;
//         end else begin
//             dtheta <= 0; // Default output when curr_period is invalid
//         end
//     end
// endmodule
// `default_nettype none
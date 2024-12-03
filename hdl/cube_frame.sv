`default_nettype none
module cube_frame #(
    parameter SCAN_RATE=32,
    parameter NUM_ROWS=64,
    parameter RGB_RES=9,
    parameter ROTATIONAL_RES=256
)
(
    input wire [$clog2(ROTATIONAL_RES)-1:0] dtheta, // discretized theta
    input wire [$clog2(SCAN_RATE)-1:0] column_index1,
    input wire [$clog2(SCAN_RATE)-1:0] column_index2,
    output logic [1:0][$clog2(NUM_ROWS)-1:0][RGB_RES-1:0] columns // presented column1, column2 in array
);

endmodule
`default_nettype none
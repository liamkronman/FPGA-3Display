`default_nettype none
module col_calc #(
    parameter ROTATIONAL_RES=256,
    parameter NUM_COLS=64 // always a power of 2
)
(
    input wire [$clog2(ROTATIONAL_RES)-1:0] dtheta,
    output logic [NUM_COLS-1:0] col_indices
);
    // point of this module: given a dtheta, tell frame_manager which columns to consider
    // ALL LOGIC HERE SHOULD BE COMBINATIONAL

    // for the time being, until we do something like simulated annealing, it makes sense to have ALL columns *always* be considered.
    always_comb begin
        for (int i = 0; i < NUM_COLS; i++) begin
            col_indices[i] = 1;
        end
    end
endmodule
`default_nettype none
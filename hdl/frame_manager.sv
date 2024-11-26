`default_nettype none
module frame_manager #(
    parameter ROTATIONAL_RES=180,
    parameter NUM_COLS=64,
    parameter NUM_ROWS=64,
    parameter SCAN_RATE=32,
    parameter THETA_RES=27,
    parameter RGB_RES=9
)
(
    input wire rst_in,
    input wire [1:0] mode, // mode 0: cylinder, mode 1: sphere, mode 2: cube, mode 3: boids
    input wire clk_in,
    input wire [THETA_RES-1:0] theta, // suppose 8 bit resolution for theta
    input wire hub75_ready, // wait for hub75 to say it's ready before streaming the two columns
    output logic [1:0][NUM_ROWS-1:0][RGB_RES-1:0] columns,
    output logic [$clog2(SCAN_RATE)-1:0] col_num1,
    output logic [$clog2(SCAN_RATE):0] col_num2,
    output logic data_valid
);
    logic [$clog2(SCAN_RATE)-1:0] col_index; // goes from 0 - 31

    logic [$clog2(NUM_COLS)-1:0] col_indices; // 1 for if that column is represented at this index, 0 if column isn't represented
                                    // used for scanline optimization
 
    logic [1:0][NUM_ROWS-1:0][RGB_RES-1:0] sphere_cols;
    logic [1:0][NUM_ROWS-1:0][RGB_RES-1:0] cube_cols;
    logic [1:0][NUM_ROWS-1:0][RGB_RES-1:0] boids_cols;

    logic [$clog2(SCAN_RATE)-1:0] col_index_intermediate;

    logic [THETA_RES-1:0] old_theta;

    // intermediate variables used to address off-by-one issue
    logic [$clog2(SCAN_RATE)-1:0] intermediate_col_num1;
    logic [$clog2(SCAN_RATE)-1:0] intermediate_col_num2;

    col_calc cc (
        .theta(theta),
        .col_indices(col_indices) // OUTPUT of cc
    );

    always_comb begin
        intermediate_col_num1 = col_index_intermediate;
        intermediate_col_num2 = col_index_intermediate+SCAN_RATE;
        col_num1 = col_index;
        col_num2 = col_index+SCAN_RATE;
    end

    sphere_frame sf ( // no need for a theta
        .column_index1(intermediate_col_num1),
        .column_index2(intermediate_col_num2),
        .columns(sphere_cols)
    );

    cube_frame cf (
        .theta(theta),
        .column_index1(intermediate_col_num1),
        .column_index2(intermediate_col_num2),
        .columns(cube_cols)
    );

    boids_frame bf (
        .theta(theta),
        .column_index1(intermediate_col_num1),
        .column_index2(intermediate_col_num2),
        .columns(boids_cols)
    );

    logic old_hub75_ready;

    always_ff @(posedge clk_in) begin
        if (rst_in || (old_theta & ~theta)) begin // reset or theta has changed
            col_index <= 0;
            col_index_intermediate <= 0;
            data_valid <= 0;
            columns <= 0;
            col_num1 <= 0;
            col_num2 <= 0;
        end else begin

            col_index <= col_index + 1;
            if (hub75_ready == 1) begin // data just became ready (maybe useless as ready is 1-cycle)
                if (col_indices[col_index_intermediate]) begin // iterates over 32 cycles
                    col_index <= col_index_intermediate;
                    case (mode)
                        2'b00: columns <= 0; // cylinder mode (TODO: FIX)
                        2'b01: columns <= sphere_cols; // sphere mode
                        2'b10: columns <= cube_cols; // cube mode
                        2'b11: columns <= boids_cols; // boids mode
                        default: columns <= sphere_cols;
                    endcase
                end
                if (col_index_intermediate == SCAN_RATE) begin
                    col_index_intermediate <= 0;
                end else begin
                    col_index_intermediate <= col_index_intermediate + 1;
                end
                // There's a problem with propagation delay of the columns
                //  * For example, in the sphere situation, the combinational computations might have a propagation delay which isn't accounted for.
                // Therefore, data_valid may not necessarily make sense to happen in the same cycle -- even if we can somehow get away with it with the 83.3ns cycle length on 12MHz.
                data_valid <= 1;

                old_theta <= theta;
                old_hub75_ready <= hub75_ready;
            end 
            if (data_valid) begin
                data_valid <= 0;
            end
        end
    end
endmodule
`default_nettype none
module frame_track #(
    parameter ROTATIONAL_RES=180,
    parameter NUM_COLS=64,
    parameter NUM_ROWS=64,
    parameter SCAN_RATE=32,
    parameter THETA_RES=8,
    parameter RGB_RES=9
)
(
    input wire rst_in,
    input wire mode,
    input wire clk_in,
    input wire [THETA_RES-1:0] theta, // suppose 8 bit resolution for theta
    output logic [1:0][$clog2(NUM_ROWS)-1:0][RGB_RES-1:0] columns,
    output logic [$clog2(SCAN_RATE)-1:0] col_num1,
    output logic [$clog2(SCAN_RATE)-1:0] col_num2,
);
    logic [$clog2(SCAN_RATE)-1:0] col_index; // goes from 0 - 31

    logic [$clog2(NUM_COL)-1:0] col_indices; // 1 for if that column is represented at this index, 0 if column isn't represented
                                    // used for scanline optimization
 
    logic [1:0][$clog2(NUM_ROWS)-1:0][RGB_RES-1:0] cube_cols;
    logic [1:0][$clog2(NUM_ROWS)-1:0][RGB_RES-1:0] boids_cols;

    logic [$clog2(SCAN_RATE)-1:0] col_index_intermediate;

    logic [THETA_RES-1:0] old_theta;

    // intermediate variables used to address off-by-one issue
    logic [$clog2(SCAN_RATE)-1:0] intermediate_col_num1;
    logic [$clog2(SCAN_RATE)-1:0] intermediate_col_num2;

    fibonacci_col_calc fcc (
        .theta(theta),
        .col_indices(col_indices) // OUTPUT of fcc
    );

    always_comb begin
        intermediate_col_num1 = col_index_intermediate;
        intermediate_col_num2 = col_index_intermediate+SCAN_RATE;
        col_num1 = col_index;
        col_num2 = col_index+SCAN_RATE;
    end

    cube_frame cf (
        .theta(theta),
        .column_index1(intermediate_col_num1),
        .column_index2(intermediate_col_num2),
        .columns(cube_cols),
    );

    boids_lookup bf (
        .theta(theta),
        .column_index1(intermediate_col_num1),
        .column_index2(intermediate_col_num2),
        .columns(boids_cols),
    );

    always_ff @(posedge clk_in) begin
        if (rst_in || old_theta & ~theta) begin // reset or theta has changed
            col_index <= 0;
            col_index_track <= 0;
        end else begin
            if (col_indices[col_index_intermediate]) {
                col_index <= col_index_intermediate;
                if (mode) begin // cube mode
                    columns <= cube_cols;
                end else begin // boids mode
                    columns <= boids_cols;
                end
            }
            col_index_intermediate <= col_index_intermediate + 1;
            old_theta <= theta;
        end
    end
endmodule
module frame_buffer #(
    parameter ROTATIONAL_RES=180,
    parameter NUM_COLS=64,
    parameter NUM_ROWS=64,
    parameter SCAN_RATE=32
)
(
    input wire rst_in,
    input wire mode,
    input wire clk_in,
    input wire [7:0] theta, // suppose 8 bit resolution for theta
    output logic [1:0][NUM_ROWS-1:0] columns,
    output logic [$clog2(SCAN_RATE)-1:0] col_num1,
    output logic [$clog2(SCAN_RATE)-1:0] col_num2,
    output logic ready,
);
    logic [SCAN_RATE-1:0] col_index; // goes from 0 - 31

    logic [NUM_COL-1:0] col_indices; // 1 for if that column is represented at this index, 0 if column isn't represented
                                    // used for scanline optimization
 
    logic [1:0][NUM_ROWS-1:0] cube_cols;
    logic [1:0][NUM_ROWS-1:0] boids_cols;

    fibonacci_col_calc fcc (
        .theta(theta),
        .col_indices(col_indices) // OUTPUT of fcc
    );

    always_comb begin
        for (int i = 0; i < SCAN_RATE; i++) { // THIS IS IDEA. DOES NOT WORK IN PRACTICE.
            if (col_indices[i]) {
                col_index = i;
            }
            col_num1 = col_index;
            col_num2 = col_index+SCAN_RATE;
        }
    end

    cube_frame cf (
        .theta(theta),
        .column_index1(col_num1),
        .column_index2(col_num2),
        .columns(cube_cols),
    );

    boids_lookup bf (
        .theta(theta),
        .column_index1(col_num1),
        .column_index2(col_num2),
        .columns(boids_cols),
    );
    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            col_index <= 0;
        end else begin
            if (mode) begin // cube mode
                columns <= cube_cols;
            end else begin // boids mode
                columns <= boids_cols;
            end
        end
    end
endmodule
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
    output logic [1:0][NUM_ROWS-1:0] column,
    output logic [SCAN_RATE-1:0] col_num1,
    output logic [SCAN_RATE-1:0] col_num2,
    output logic ready,
);
    logic [SCAN_RATE-1:0] col_index; // goes from 0 - 31

    logic [NUM_COL-1:0] col_indices; // 1 for if that column is represented at this index, 0 if column isn't represented
                                    // used for scanline optimization
 
    logic [SCAN_RATE-1:0] cube_col1;
    logic [SCAN_RATE-1:0] cube_col2;
    logic [SCAN_RATE-1:0] boids_col1;
    logic [SCAN_RATE-1:0] boids_col2;

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
        .column1(cube_col1),
        .column2(cube_col2),
    );

    boids_lookup bf (
        .theta(theta),
        .column_index1(col_index),
        .column_index2(col_index+SCAN_RATE),
        .column1(boids_col1),
        .column2(boids_col2)

    );
    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            col_index <= 0;
        end else begin
            if (mode) begin // cube mode
                col_num1 <= cube_col1;
                col_num2 <= cube_col2;
            end else begin // boids mode
                col_num1 <= boids_col1;
                col_num2 <= boids_col2;
            end
        end
    end
endmodule
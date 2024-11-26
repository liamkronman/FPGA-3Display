`default_nettype none
module sphere_frame #(
    parameter SCAN_RATE=32,
    parameter NUM_COLS=64,
    parameter NUM_ROWS=64,
    parameter RGB_RES=9
)
(
    input wire [$clog2(SCAN_RATE)-1:0] column_index1,
    input wire [$clog2(SCAN_RATE):0] column_index2,
    output logic [1:0][NUM_ROWS-1:0][RGB_RES-1:0] columns // presented column1, column2 in array
);
    // given the two column indices, return the points on the circle that lie on those columns
    
    // PLAN: approach this mathematically first, and explore BRAM/SRAM if that method starts choking.

    // test: turn all white. doesn't depend on column_index's
    always_comb begin
        // Set all rows in both columns to high
        for (int y = 0; y < NUM_ROWS; y++) begin
            columns[0][y] = {RGB_RES{1'b1}}; // Set all bits in RGB_RES to 1
            columns[1][y] = {RGB_RES{1'b1}}; // Set all bits in RGB_RES to 1
        end
    end

    // localparam int RADIUS = NUM_ROWS / 2; // NUM_ROWS == NUM_ROWS for our system
    // localparam int CENTER_X = NUM_COLS / 2;
    // localparam int CENTER_Y = NUM_ROWS / 2;

    // logic [$clog2(NUM_ROWS)-1:0][RGB_RES-1:0] column1, column2;
    // logic [$clog2(SCAN_RATE)-1:0] x1, x2, y_offset;

    // always_comb begin
    //     for (int y = 0; y < NUM_ROWS; y++) begin
    //         column1[y] = '0;
    //         column2[y] = '0;
    //     end

    //     for (int y = 0; y < NUM_ROWS; y++) begin
    //         x1 = column_index1 - CENTER_X;
    //         x2 = column_index2 - CENTER_X;
    //         y_offset = y - CENTER_Y;

    //         if ((x1 * x1 + y_offset * y_offset) <= (RADIUS * RADIUS)) begin
    //             column1[y] = {RGB_RES{1'b1}};;
    //         end
    //         if ((x2 * x2 + y_offset * y_offset) <= (RADIUS * RADIUS)) begin
    //             column2[y] = {RGB_RES{1'b1}};;
    //         end
    //     end

    //     columns[0] = column1;
    //     columns[1] = column2;
    // end

endmodule
`default_nettype none
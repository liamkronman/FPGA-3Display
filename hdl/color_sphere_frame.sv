// SAME AS SPHERE_FRAME BUT INCORPORATES DTHETA FOR DYNAMIC COLOR

`default_nettype none
module color_sphere_frame #(
    parameter ROTATIONAL_RES=256,
    parameter SCAN_RATE=32,
    parameter NUM_COLS=64,
    parameter NUM_ROWS=64,
    parameter RGB_RES=9
)
(
    input wire [$clog2(ROTATIONAL_RES)-1:0] dtheta, // discretized theta
    input wire [$clog2(SCAN_RATE)-1:0] column_index1,
    input wire [$clog2(SCAN_RATE):0] column_index2,
    output logic [1:0][NUM_ROWS-1:0][RGB_RES-1:0] columns // presented column1, column2 in array
);
    // given the two column indices, return the points on the circle that lie on those columns
    
    localparam int RADIUS = 20; // NUM_ROWS == NUM_ROWS for our system
    localparam int CENTER_X = NUM_COLS / 2;
    localparam int CENTER_Y = NUM_ROWS / 2;

    logic [NUM_ROWS-1:0][RGB_RES-1:0] column1, column2;
    logic [$clog2(SCAN_RATE):0] x1, x2, y_offset;

    always_comb begin
        for (int y = 0; y < NUM_ROWS; y++) begin
            column1[y] = '0;
            column2[y] = '0;
        end

        x1 = CENTER_X - column_index1; // column_index1 < CENTER_X
        x2 = column_index2 - CENTER_X ;

        for (int y = 0; y < NUM_ROWS/2; y++) begin
            y_offset = CENTER_Y - y; // CENTER_Y > y

            if ((x1 * x1 + y_offset * y_offset) <= (RADIUS * RADIUS)) begin
                if (dtheta < (ROTATIONAL_RES >> 1)) begin
                    column1[y] = {RGB_RES{1'b1}}; // TODO: this code assumes 9-bit color res and 8-bit dtheta.
                end else begin
                    column1[y] = {RGB_RES{1'b0}};
                end
            end
            if ((x2 * x2 + y_offset * y_offset) <= (RADIUS * RADIUS)) begin
                if (dtheta < (ROTATIONAL_RES >> 1)) begin
                    column2[y] = {RGB_RES{1'b0}}; // TODO: this code assumes 9-bit color res and 8-bit dtheta.
                end else begin
                    column2[y] = {RGB_RES{1'b1}};
                end
            end
        end
        for (int y = NUM_ROWS/2; y < NUM_ROWS; y++) begin
            y_offset = y - CENTER_Y; // y > CENTER_Y

            // if ((x1 * x1 + y_offset * y_offset) <= (RADIUS * RADIUS)) begin
            //     column1[y] = { 1'b0, dtheta }; // TODO: this code assumes 9-bit color res and 8-bit dtheta.
            // end
            // if ((x2 * x2 + y_offset * y_offset) <= (RADIUS * RADIUS)) begin
            //     column2[y] = { 1'b0, dtheta }; // TODO: this code assumes 9-bit color res and 8-bit dtheta.
            // end
            if ((x1 * x1 + y_offset * y_offset) <= (RADIUS * RADIUS)) begin
                if (dtheta < (ROTATIONAL_RES >> 1)) begin
                    column1[y] = {RGB_RES{1'b1}}; // TODO: this code assumes 9-bit color res and 8-bit dtheta.
                end else begin
                    column1[y] = {RGB_RES{1'b0}};
                end
            end
            if ((x2 * x2 + y_offset * y_offset) <= (RADIUS * RADIUS)) begin
                if (dtheta < (ROTATIONAL_RES >> 1)) begin
                    column2[y] = {RGB_RES{1'b0}}; // TODO: this code assumes 9-bit color res and 8-bit dtheta.
                end else begin
                    column2[y] = {RGB_RES{1'b1}};
                end
            end
        end

        columns[0] = column1;
        columns[1] = column2;
    end

endmodule
`default_nettype none
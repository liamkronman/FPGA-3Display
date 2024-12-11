`default_nettype none
module frame_manager #(
    parameter ROTATIONAL_RES=1024,
    parameter NUM_COLS=64,
    parameter NUM_ROWS=64,
    parameter SCAN_RATE=32,
    parameter RGB_RES=9
)
(
    input wire rst_in,
    input wire [1:0] mode, // mode 0: cylinder, mode 1: sphere, mode 2: cube, mode 3: boids
    input wire clk_in,
    input wire [$clog2(ROTATIONAL_RES)-1:0] dtheta, // where we currently are in the rotation (discretized within [0,ROTATIONAL_RES))
    input wire hub75_ready, // wait for hub75 to say it's ready before streaming the two columns
    input wire hub75_last,
    output logic [1:0][NUM_ROWS-1:0][RGB_RES-1:0] columns,
    output logic [$clog2(SCAN_RATE)-1:0] col_num1,
    output logic [$clog2(SCAN_RATE):0] col_num2,
    output logic data_valid
);
    logic [$clog2(SCAN_RATE)-1:0] col_index; // goes from 0 - 31

    logic [NUM_COLS-1:0] col_indices; // 1 for if that column is represented at this index, 0 if column isn't represented
                                    // used for scanline optimization
 
    logic [1:0][NUM_ROWS-1:0][RGB_RES-1:0] sphere_cols;
    logic [1:0][NUM_ROWS-1:0][RGB_RES-1:0] cube_cols;
    logic [1:0][NUM_ROWS-1:0] rfb_cols;
    logic [1:0][NUM_ROWS-1:0][RGB_RES-1:0] boids_cols;

    logic [$clog2(SCAN_RATE)-1:0] col_index_intermediate;

    logic [$clog2(ROTATIONAL_RES)-1:0] old_dtheta;

    // intermediate variables used to address off-by-one issue
    logic [$clog2(SCAN_RATE)-1:0] intermediate_col_num1;
    logic [$clog2(SCAN_RATE)-1:0] intermediate_col_num2;

    logic [1:0][$clog2(SCAN_RATE)-1:0] rfb_radii;
    logic [$clog2(SCAN_RATE)-1:0] rfb_col_num;

    logic rfb_busy; 

    col_calc cc (
        .dtheta(dtheta),
        .col_indices(col_indices) // OUTPUT of cc
    );

    always_comb begin
        
        
        // col_num1 = col_index;
        col_num2 = col_index+SCAN_RATE;
        intermediate_col_num1 = (mode == 2'b10)  ? rfb_col_num :  col_index_intermediate; //if in cube mode

        intermediate_col_num2 = intermediate_col_num1+SCAN_RATE;

        
    end

    sphere_frame sf ( // no need for a theta
        .column_index1(col_index_intermediate),
        .column_index2(col_index_intermediate+SCAN_RATE),
        .columns(sphere_cols)
    );

    // color_sphere_frame sf (
    //     .dtheta(dtheta),
    //     .column_index1(col_index_intermediate),
    //     .column_index2(col_index_intermediate+SCAN_RATE),
    //     .columns(sphere_cols)
    // );

    // hemi_sphere_frame sf(
    //     .dtheta(dtheta),
    //     .column_index1(col_index_intermediate),
    //     .column_index2(col_index_intermediate+SCAN_RATE),
    //     .columns(sphere_cols)
    // );

    /*cube_frame cf (
        .dtheta(dtheta),
        .column_index1(intermediate_col_num1),
        .column_index2(intermediate_col_num2),
        .columns(cube_cols)
    );*/

    logic ball_frame;
    logic ball_frame_busy;

    logic [5:0] ball_x;
    logic [5:0] ball_y;
    logic [5:0] ball_z;


    ball_simulation bs (
        .rst_in(rst_in),
        .clk_in(clk_in),
        .new_frame(dtheta==0),
        .ball_frame_busy(ball_frame_busy),
        .ball_frame(ball_frame),
        .box_frame_busy(0),
        .box_frame(0),
        .ball_x(ball_x),
        .ball_y(ball_y),
        .ball_z(ball_z)
    );


    logic flush;
    logic write_frame_buffer;
    logic [$clog2(ROTATIONAL_RES)-1:0] draw_theta;
    logic [5:0] draw_radius;
    logic [5:0] draw_z;

    draw_ball db (

    // input wire rst_in,
    // input wire clk_in,

    // input wire ball_frame,

    // output logic flush,
    // output logic write_frame_buffer,
    // output logic [$clog2(ROTATIONAL_RES)-1:0] draw_theta,
    // output logic [4:0] draw_radius,
    // output logic [5:0] draw_z,

    // input wire buffer_busy
        .rst_in(rst_in),
        .clk_in(clk_in),
        .ball_frame(ball_frame),
        .busy(ball_frame_busy),
        .flush(flush),
        .write_frame_buffer(write_frame_buffer),
        
        .ball_x(ball_x), //Origin of the ball
        .ball_y(ball_y),
        .ball_z(ball_z),

        .draw_theta(draw_theta),
        .draw_radius(draw_radius),
        .draw_z(draw_z)

    );



    boids_frame bf (
        .dtheta(dtheta),
        .column_index1(intermediate_col_num1),
        .column_index2(intermediate_col_num2),
        .columns(boids_cols)
    );

    rot_frame_buffer rfb (
        .rst_in(rst_in),
        .clk_in(clk_in),
        .flush(flush),
        .new_data(write_frame_buffer),
        .theta_write(draw_theta),
        .radius(draw_radius),
        .z(draw_z),
        .theta_read(dtheta),
        .radii(rfb_radii),
        .busy(rfb_busy),
        .columns(rfb_cols)

    );
    logic rfb_data_valid;
    rot_frame_buffer_to_hub75 rfb_to_hub75 (
        .rst_in(rst_in),
        .clk_in(clk_in),
        .hub75_ready(hub75_ready),
        .hub75_last(hub75_last),
        .radii_input(rfb_radii),
        .rfb_cols_input(rfb_cols),
        .data_valid(rfb_data_valid),
        .col_num(rfb_col_num),
        .columns(cube_cols),
        .theta(dtheta)


    );



    logic old_hub75_ready;


    always_ff @(posedge clk_in) begin
        if (rst_in) begin // reset or theta has changed
            col_index <= 0;
            col_index_intermediate <= 0;
            data_valid <= 0;
            columns <= 0;
            col_num1 <= 0;
            col_num2 <= 0;
        end else begin

            if (1) begin // data just became ready (maybe useless as ready is 1-cycle)
                // col_num1 <= col_num1 + 1;
                // columns <= sphere_cols;
                // col_index_intermediate <= col_index_intermediate + 1;
                    col_num1 <= intermediate_col_num1;
                    case (mode)
                        2'b00: columns <= 0; // cylinder mode (TODO: FIX)
                        2'b01: columns <= sphere_cols; // sphere mode
                        2'b10: columns <= cube_cols; // cube mode
                        2'b11: columns <= boids_cols; // boids mode

                        default: columns <= sphere_cols;
                    endcase
                if (col_index_intermediate + 1 == SCAN_RATE) begin
                    col_index_intermediate <= 0;
                end else begin
                    col_index_intermediate <= col_index_intermediate + 1;
                end
                // There's a problem with propagation delay of the columns
                //  * For example, in the sphere situation, the combinational computations might have a propagation delay which isn't accounted for.
                // Therefore, data_valid may not necessarily make sense to happen in the same cycle -- even if we can somehow get away with it with the 83.3ns cycle length on 12MHz.
                data_valid <= 1;

                old_dtheta <= dtheta;
                
            end 
            /*if (data_valid) begin
                data_valid <= 0;
            end*/
            old_hub75_ready <= hub75_ready;
        end
    end
endmodule
`default_nettype none
`timescale 1ns / 1ps
`default_nettype none

`ifdef SYNTHESIS
`define FPATH(X) `"X`"
`else /* ! SYNTHESIS */
`define FPATH(X) `"../data/X`"
`endif  /* ! SYNTHESIS */

/*
TODO:
1. 


*/

module bouncy_ball
#( parameter ROTATIONAL_RES = 1024,
  parameter BALL_RAM_DEPTH = 389,
  parameter DISPLAY_RADIUS = 32,
  parameter DISPLAY_HEIGHT = 64,
  parameter DATA_SIZE = 1
) (
    input wire rst_in,
    input wire clk_in,

    input wire ball_frame,
    input wire [$clog2(ROTATIONAL_RES)-1:0] theta_read, // Dual purpose, used for addressing reads and writes

    output logic [1:0][DISPLAY_HEIGHT*DATA_SIZE-1:0] columns,
    output logic [1:0][$clog2(DISPLAY_RADIUS)-1:0] radii
    
);

    logic [$clog2(BALL_RAM_DEPTH)-1:0] ball_addr;

    logic [5:0] ball_x; //Origin of the ball
    logic [5:0] ball_y;
    logic [5:0] ball_z;

    assign ball_x = 0;
    assign ball_y = 32;
    assign ball_z = 32;

    logic [5:0] ball_offset_x;
    logic [5:0] ball_offset_y;
    logic [5:0] ball_offset_z;

    logic [5:0] draw_ball_x;
    logic [5:0] draw_ball_y;
    logic [5:0] draw_ball_z;

    logic [6:0] extended_ball_x; // Used for determining overfill and underfill
    logic [6:0] extended_ball_y;
    logic [6:0] extended_ball_z;

    logic flush;
    logic buffer_busy;
    logic busy;


    logic [$clog2(5):0] draw_timer;
    logic [$clog2(5):0] wait_timer;


    logic exceeded;
    logic [4:0] draw_radius;
    logic [$clog2(ROTATIONAL_RES)-1:0] draw_theta;
    logic [5:0] draw_z;        // Different from draw_ball_z, this is the z 
                               // value in cylindrical coordinates

    logic write_frame_buffer;


    xilinx_single_port_ram_read_first #(
        // .RAM_WIDTH($clog2(RANGE/2)),                       // Specify RAM data width
        .RAM_WIDTH(18),                       // Specify RAM data width
        .RAM_DEPTH(BALL_RAM_DEPTH),                     // Specify RAM depth (number of entries)
        .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
        .INIT_FILE(`FPATH(sphere_points.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
    ) sphere_ram (
        .addra(ball_addr),     // Address bus, width determined from RAM_DEPTH
        .dina(1'b0),       // RAM input data, width determined from RAM_WIDTH
        .clka(clk_in),       // Clock
        .wea(1'b0),         // Write enable
        .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
        .rsta(rst_in),       // Output reset (does not affect memory contents)
        .regcea(1'b1),   // Output register enable
        .douta({ball_offset_x, ball_offset_y, ball_offset_z})      // RAM output data, width determined from RAM_WIDTH
    );

    rot_frame_buffer #(
      .ROTATIONAL_RES(ROTATIONAL_RES)
    ) rfb (
        .rst_in(rst_in),
        .clk_in(clk_in),
        .flush(flush),
        .new_data(write_frame_buffer),
        .theta_write(draw_theta),
        .radius(draw_radius),
        .z(draw_z),
        .theta_read(theta_read),
        .busy(buffer_busy),
        .columns(columns),
        .radii(radii)
    );

    cartesian_to_cylindrical #(
        .ROTATIONAL_RES(ROTATIONAL_RES)
    ) ctc (
        .rst_in(rst_in),
        .clk_in(clk_in),
        .x_in(draw_ball_x),
        .y_in(draw_ball_y),
        .z_in(draw_ball_z),
        .theta(draw_theta),
        .radius({exceeded, draw_radius}),
        .z_out(draw_z)
    );


    // typedef enum { IDLE, DRAW, FLUSH } state;
    typedef enum { IDLE, DRAW, FLUSH, WAIT } state;

    state sim_state;
    
    
    assign busy = (sim_state != IDLE);
    always_comb begin
        
        extended_ball_x = {1'b0, ball_x} + {ball_offset_x[5] ? 1'b1 : 1'b0, ball_offset_x};
        extended_ball_y = {1'b0, ball_y} + {ball_offset_y[5] ? 1'b1 : 1'b0, ball_offset_y};
        extended_ball_z = {1'b0, ball_z} + {ball_offset_z[5] ? 1'b1 : 1'b0, ball_offset_z};
        
        if (extended_ball_x < 64 && extended_ball_y < 64 && extended_ball_z < 64) begin
            draw_ball_x = extended_ball_x;
            draw_ball_y = extended_ball_y;
            draw_ball_z = extended_ball_z;
        end else begin
            draw_ball_x = 0; // This will put the ball off screen, and make the
            draw_ball_y = 0; // radius greater than 31, making it invisible with
            draw_ball_z = 0; // writing logic in DRAW state
        end


    end

    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            sim_state <= IDLE;
            ball_addr <= 0;
            draw_timer <= 0;
            // wait_timer <= 0;
            write_frame_buffer <= 1'b0;


        end else begin
            case(sim_state)
                IDLE: begin
                    write_frame_buffer <= 1'b0;
                    if (ball_frame & !buffer_busy) begin
                        sim_state <= FLUSH;
                        flush <= 1'b1;
                    end
                end
                FLUSH: begin
                    flush <= 1'b0;
                    if (!buffer_busy) begin
                        sim_state <= DRAW;

                        ball_addr <= 0;
                        draw_timer <= 1; // When this reaches 4, then a write 
                                         // will be issued to frame buffer
                                         // Start at one because the first write
                    end
                end
                DRAW: begin

                    if (draw_timer == 4) begin
                        // DRAW LOGIC????
                        if (exceeded) begin
                            write_frame_buffer <= 1'b0;
                        end else begin
                            write_frame_buffer <= 1'b1;
                        end

                        ball_addr <= ball_addr + 1;
                        draw_timer <= 0;

                        if (ball_addr == BALL_RAM_DEPTH-2) begin
                            // sim_state <= IDLE;
                            sim_state <= WAIT;
                            wait_timer <= 4; // Wait for 4 cycles before going back to IDLE
                        end
                    end else begin
                        // write_frame_buffer <= 1'b0;
                        draw_timer <= draw_timer + 1;
                    end


                end
                WAIT: begin
                    // write_frame_buffer <= 1'b0;
                    if (wait_timer == 0) begin
                        sim_state <= IDLE;
                    end else begin
                        wait_timer <= wait_timer - 1;
                    end

                end
                default: begin
                    sim_state <= IDLE;
                end
            endcase
        end
    end


endmodule
`default_nettype none
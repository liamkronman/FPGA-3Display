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

module ball_simulation
#( parameter ROTATIONAL_RES = 1024,
  parameter BALL_RAM_DEPTH = 389,
  parameter DISPLAY_RADIUS = 32,
  parameter DISPLAY_HEIGHT = 64,
  parameter DATA_SIZE = 1
) (
    input wire rst_in,
    input wire clk_in,

    input wire new_frame,

    input wire ball_frame_busy,
    output logic ball_frame,
    output logic [5:0] ball_x,  // Origin of the ball
    output logic [5:0] ball_y,
    output logic [5:0] ball_z,

    input wire box_frame_busy,
    output logic box_frame

);

    typedef enum  { IDLE, DRAW_SPHERE, DRAW_CUBE } sim_state;

    sim_state state;

    logic [2:0] ball_velocity;
    logic [2:0][5:0] ball_pos;

    assign {ball_x, ball_y, ball_z} = ball_pos;

    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            state <= IDLE;
            ball_frame <= 0;

            for (int i = 0; i < 3; i++) begin
                ball_pos[i] <= 20 + i*4;
            end
            box_frame <= 0;

            ball_velocity <= 3'b111;
        end else begin
            case (state)
                IDLE: begin
                    if (new_frame) begin
                        state <= DRAW_SPHERE;
                        
                        
                        for (int i = 0; i < 3; i++) begin
                            if (ball_velocity[i]) begin
                                ball_pos[i] <= ball_pos[i] + 1;
                            end else begin
                                ball_pos[i] <= ball_pos[i] - 1;
                            end

                            if (ball_pos[i] < 10+4) begin
                                ball_velocity[i] <= 1;
                            end else if (ball_pos[i] > 54-4) begin
                                ball_velocity[i] <= 0;
                            end

                        end

                        ball_frame <= 1;
                    end
                end
                DRAW_SPHERE: begin
                    ball_frame <= 0;
                    if (!ball_frame_busy & !ball_frame) begin
                        state <= IDLE;
                    end
                end
                DRAW_CUBE: begin
                    if (box_frame_busy) begin
                        state <= IDLE;
                    end
                end
            endcase
        end
    end



endmodule
`default_nettype none
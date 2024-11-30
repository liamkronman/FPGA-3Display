`timescale 1ns / 1ps
`default_nettype none

`ifdef SYNTHESIS
`define FPATH(X) `"X`"
`else /* ! SYNTHESIS */
`define FPATH(X) `"../data/X`"
`endif  /* ! SYNTHESIS */


module distance_3d #(
    parameter MAX_DISTANCE = 32,
    parameter RANGE = 64
)(
    input wire rst_in,
    input wire clk_in,
    input wire [4:0] x1_in,
    input wire [4:0] y1_in,
    input wire [4:0] z1_in,
    input wire [4:0] x2_in,
    input wire [4:0] y2_in,
    input wire [4:0] z2_in,
    input wire new_data,
    output logic [4:0] distance,
    output logic data_ready,
    output logic exceeded
);
    logic [4:0] x_diff;
    logic [4:0] y_diff;
    logic [4:0] z_diff;
    logic [4:0] z_diff_pipe [1:0];

    logic [$clog2(RANGE*RANGE/4)-1:0] distance_2d_addr;
    logic [$clog2(RANGE*RANGE/4)-1:0] distance_3d_addr;

    logic [4:0] distance_2d;

    // logic data_ready_pipe;
    logic exceeded_xy;
    logic exceeded_z;

    logic exceeded_xy_pipe [1:0];
    logic data_ready_pipe [4-1:0];


    xilinx_single_port_ram_read_first #(
        // .RAM_WIDTH($clog2(RANGE/2)),                       // Specify RAM data width
        .RAM_WIDTH(6),                       // Specify RAM data width
        .RAM_DEPTH(RANGE*RANGE/4),                     // Specify RAM depth (number of entries)
        .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
        .INIT_FILE(`FPATH(distance_2D.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
    ) distance_ram_xy (
        .addra(distance_2d_addr),     // Address bus, width determined from RAM_DEPTH
        .dina(1'b0),       // RAM input data, width determined from RAM_WIDTH
        .clka(clk_in),       // Clock
        .wea(1'b0),         // Write enable
        .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
        .rsta(rst_in),       // Output reset (does not affect memory contents)
        .regcea(1'b1),   // Output register enable
        .douta({exceeded_xy, distance_2d})      // RAM output data, width determined from RAM_WIDTH
    );

    xilinx_single_port_ram_read_first #(
        // .RAM_WIDTH($clog2(RANGE/2)),                       // Specify RAM data width
        .RAM_WIDTH(6),                       // Specify RAM data width
        .RAM_DEPTH(RANGE*RANGE/4),                     // Specify RAM depth (number of entries)
        .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
        .INIT_FILE(`FPATH(distance_2D.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
    ) distance_ram_z (
        .addra(distance_3d_addr),     // Address bus, width determined from RAM_DEPTH
        .dina(1'b0),       // RAM input data, width determined from RAM_WIDTH
        .clka(clk_in),       // Clock
        .wea(1'b0),         // Write enable
        .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
        .rsta(rst_in),       // Output reset (does not affect memory contents)
        .regcea(1'b1),   // Output register enable
        .douta({exceeded_z, distance})      // RAM output data, width determined from RAM_WIDTH
    );



    always_comb begin
        x_diff = x1_in > x2_in ? x1_in - x2_in : x2_in - x1_in;
        y_diff = y1_in > y2_in ? y1_in - y2_in : y2_in - y1_in;
        z_diff = z1_in > z2_in ? z1_in - z2_in : z2_in - z1_in;

        distance_2d_addr = (y_diff * RANGE/2) + x_diff;
        distance_3d_addr = (z_diff_pipe[1] * RANGE/2) + distance_2d;

        exceeded = exceeded_xy_pipe[1] | exceeded_z;
        data_ready = data_ready_pipe[3];
    end

    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            data_ready <= 1'b0;
            // data_ready_pipe <= 1'b0;

        end else begin
            // data_ready <= data_ready_pipe;
            // data_ready_pipe <= 1'b1;
            data_ready_pipe[0] <= new_data;

            for (int i = 1; i < 4; i = i+1) begin
                data_ready_pipe[i] <= data_ready_pipe[i-1];
            end

            z_diff_pipe[0] <= z_diff;
            z_diff_pipe[1] <= z_diff_pipe[0];

            exceeded_xy_pipe[0] <= exceeded_xy;
            exceeded_xy_pipe[1] <= exceeded_xy_pipe[0];

        end
    end



endmodule


`default_nettype none
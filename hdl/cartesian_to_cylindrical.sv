`timescale 1ns / 1ps
`default_nettype none

`ifdef SYNTHESIS
`define FPATH(X) `"X`"
`else /* ! SYNTHESIS */
`define FPATH(X) `"../data/X`"
`endif  /* ! SYNTHESIS */


module cartesian_to_cylindrical #(
    parameter RANGE = 64,
    parameter ROTATIONAL_RESOLUTION = 1024
)(
    input wire rst_in,
    input wire clk_in,
    input wire [7:0] x_in,
    input wire [7:0] y_in,
    input wire [7:0] z_in,
    input wire new_data,
    output logic [$clog2(ROTATIONAL_RESOLUTION)-1:0] theta,
    // output logic [$clog2(RANGE/2)-1:0] radius,
    output logic [5:0] radius,
    output logic [5:0] z_out,
    output logic data_ready
);

    logic data_ready_pipe;
    logic [5:0] z_pipe;

    logic [7:0] squared_distance;
    logic [5:0] x_int; 
    logic [5:0] y_int;
    
    // Removes the fixed point
    // HHAHAHA NEVERMIND 
    assign x_int = (x_in);
    assign y_int = (y_in);

    // assign squared_distance = (x_int * x_int - 32) + (y_int * y_int - 32);

    logic [$clog2(RANGE*RANGE)-1:0] arctan_addr;
    assign arctan_addr = (y_int * RANGE) + x_int;

    logic [$clog2(RANGE*RANGE/4)-1:0] distance_2d_addr;
    always_comb begin

        unique case ({x_int[5], y_int[5]})
            2'b00: distance_2d_addr = 
                ((5'h1F - y_int[4:0]) * (RANGE/2)) + 5'h1F - x_int[4:0]; // Lower left
                
            2'b01: distance_2d_addr = 
                (y_int[4:0] * (RANGE/2)) + 5'h1F - x_int[4:0]; // Lower right
                
            2'b10: distance_2d_addr = 
                ((5'h1F - y_int[4:0]) * (RANGE/2)) + x_int[4:0]; // Upper left
                
            2'b11: distance_2d_addr = 
                (y_int[4:0] * (RANGE/2)) + x_int[4:0]; // Upper right
                
            default: distance_2d_addr = 0;
        endcase
    end


    //  Xilinx Single Port Read First RAM
    xilinx_single_port_ram_read_first #(
        .RAM_WIDTH($clog2(ROTATIONAL_RESOLUTION)),                       // Specify RAM data width
        .RAM_DEPTH(RANGE*RANGE),                     // Specify RAM depth (number of entries)
        .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
        .INIT_FILE(`FPATH(arctan2.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
    ) arctan_ram (
        .addra(arctan_addr),     // Address bus, width determined from RAM_DEPTH
        .dina(1'b0),       // RAM input data, width determined from RAM_WIDTH
        .clka(clk_in),       // Clock
        .wea(1'b0),         // Write enable
        .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
        .rsta(rst_in),       // Output reset (does not affect memory contents)
        .regcea(1'b1),   // Output register enable
        .douta(theta)      // RAM output data, width determined from RAM_WIDTH
    );
    
    //  Xilinx Single Port Read First RAM
    xilinx_single_port_ram_read_first #(
        // .RAM_WIDTH($clog2(RANGE/2)),                       // Specify RAM data width
        .RAM_WIDTH(6),                       // Specify RAM data width
        .RAM_DEPTH(RANGE*RANGE/4),                     // Specify RAM depth (number of entries)
        .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
        .INIT_FILE(`FPATH(distance_2D.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
    ) distance_ram (
        .addra(distance_2d_addr),     // Address bus, width determined from RAM_DEPTH
        .dina(1'b0),       // RAM input data, width determined from RAM_WIDTH
        .clka(clk_in),       // Clock
        .wea(1'b0),         // Write enable
        .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
        .rsta(rst_in),       // Output reset (does not affect memory contents)
        .regcea(1'b1),   // Output register enable
        .douta(radius)      // RAM output data, width determined from RAM_WIDTH
    );

    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            data_ready_pipe <= 0;
            z_pipe <= 0;

            data_ready <= 0;
            z_out <= 0;
        end else begin

            // Pipelines take two clock cycles
            // z_pipe <= z_in >> 2;
            z_pipe <= z_in;
            data_ready_pipe <= new_data;

            z_out <= z_pipe;
            data_ready <= data_ready_pipe;
            
        end
    end
endmodule



`default_nettype none
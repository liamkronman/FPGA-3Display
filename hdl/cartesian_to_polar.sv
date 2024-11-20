module cartesian_to_cylindrical (
    input wire rst_in,
    input wire clk_in,
    input wire [7:0] x,
    input wire [7:0] y,
    input wire [7:0] z,
    output logic [7:0] theta,
    output logic [7:0] radius,
    output logic data_ready
);

    logic [7:0] squared_distance;

    // //  Xilinx Single Port Read First RAM
    // xilinx_single_port_ram_read_first #(
    //     .RAM_WIDTH(8),                       // Specify RAM data width
    //     .RAM_DEPTH(WIDTH*HEIGHT),                     // Specify RAM depth (number of entries)
    //     .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    //     .INIT_FILE(`FPATH(image2.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
    // ) image_ram (
    //     .addra(image_addr),     // Address bus, width determined from RAM_DEPTH
    //     .dina(1'b0),       // RAM input data, width determined from RAM_WIDTH
    //     .clka(pixel_clk_in),       // Clock
    //     .wea(1'b0),         // Write enable
    //     .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
    //     .rsta(rst_in),       // Output reset (does not affect memory contents)
    //     .regcea(1'b1),   // Output register enable
    //     .douta(palette_addr)      // RAM output data, width determined from RAM_WIDTH
    // );


endmodule
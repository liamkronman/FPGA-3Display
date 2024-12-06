`timescale 1ns / 1ps
`default_nettype none

`ifdef SYNTHESIS
`define FPATH(X) `"X`"
`else /* ! SYNTHESIS */
`define FPATH(X) `"../data/X`"
`endif  /* ! SYNTHESIS */

/*
TODO:
1. Create flushing logic
- modify write enable logic so that both brams can be flushed at once
- create a theta_flush so to keep track of the theta value during flushing

2. Create writing logic, which will write when the state is not flushing 
  in four clock cycles, two for reading, two for writing and modifying
  the read value if the flag is set. Essentially oring the column data

3. Create reading logic, should be mostly combinational

4. Chill out and have a beer


*/

module rot_frame_buffer
#( parameter ROTATIONAL_RES = 1024,
  parameter DISPLAY_RADIUS = 32,
  parameter DISPLAY_HEIGHT = 64,
  parameter DATA_SIZE = 1,
  parameter COLUMN_DATA_WIDTH = DISPLAY_HEIGHT*DATA_SIZE + $clog2(DISPLAY_RADIUS)
) (
    input wire rst_in,
    input wire clk_in,
    input wire flush,
    
    input wire new_data,
    input wire [$clog2(DISPLAY_RADIUS)-1:0] radius,
    input wire [$clog2(ROTATIONAL_RES)-1:0] theta_write, // Dual purpose, used for addressing reads and writes
    input wire [$clog2(DISPLAY_HEIGHT)-1:0] z,
    
    input wire [$clog2(ROTATIONAL_RES)-1:0] theta_read, // Dual purpose, used for addressing reads and writes

    output logic busy,
    output logic data_ready,
    // output logic row_out,
    output logic [1:0][DISPLAY_HEIGHT*DATA_SIZE-1:0] columns,
    output logic [1:0][$clog2(DISPLAY_RADIUS)-1:0] radii
);

  logic [COLUMN_DATA_WIDTH-1:0] new_column; // Extra bit to keep state on writes
  logic [COLUMN_DATA_WIDTH-1:0] current_column;
  logic [COLUMN_DATA_WIDTH-1:0] row_1_out;
  logic [COLUMN_DATA_WIDTH-1:0] row_2_out;

  logic [$clog2(ROTATIONAL_RES)-1:0] theta;
  logic [$clog2(ROTATIONAL_RES)-1:0] theta_pipe [1:0];

  logic [$clog2(ROTATIONAL_RES/2)-1:0] flush_theta;
  logic [$clog2(ROTATIONAL_RES/2)-1:0] addr_theta; //DO NOT TOUCH

  logic write_enable; // For writing to the buffer in the write state


  // The following is an instantiation template for xilinx_single_port_ram_read_first
  //  Xilinx Single Port Read First RAM
  xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(COLUMN_DATA_WIDTH),  // Specify RAM data width
    .RAM_DEPTH(ROTATIONAL_RES/2),       // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(cube_buffer_1.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) buffer_0_to_pi (
    .addra(addr_theta),                        // Address bus, width determined from RAM_DEPTH
    .dina(new_column),                    // RAM input data, width determined from RAM_WIDTH
    .clka(clk_in),                        // Clock
    .wea(wea_1),         // Write enable
    .ena(1'b1),                           // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),                        // Output reset (does not affect memory contents)
    .regcea(1'b1),                        // Output register enable
    .douta(row_1_out)                     // RAM output data, width determined from RAM_WIDTH
  );

  // The following is an instantiation template for xilinx_single_port_ram_read_first
  //  Xilinx Single Port Read First RAM
  xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(COLUMN_DATA_WIDTH),  // Specify RAM data width
    .RAM_DEPTH(ROTATIONAL_RES/2),       // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(cube_buffer_2.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) buffer_pi_to_2pi (
    .addra(addr_theta),                        // Address bus, width determined from RAM_DEPTH
    .dina(new_column),                    // RAM input data, width determined from RAM_WIDTH
    .clka(clk_in),                        // Clock
    .wea(wea_2),         // Write enable
    .ena(1'b1),                           // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),                        // Output reset (does not affect memory contents)
    .regcea(1'b1),                        // Output register enable
    .douta(row_2_out)                     // RAM output data, width determined from RAM_WIDTH
  );

  
  logic wea_1;
  logic wea_2;
  
  typedef enum { IDLE, FLUSHING, WRITING, WAIT } buffer_state;
  
  buffer_state state;
  logic [COLUMN_DATA_WIDTH-1:0] old_column;
  
  always_comb begin

    busy = state != IDLE;
    old_column = theta_pipe[1] < ROTATIONAL_RES/2 ? row_1_out : row_2_out;

    current_column = 1'b1 << z*DATA_SIZE;
    current_column[COLUMN_DATA_WIDTH-1: COLUMN_DATA_WIDTH-$clog2(DISPLAY_RADIUS)] = radius;

    if (state == FLUSHING) begin
      wea_1 = 1'b1;
      wea_2 = 1'b1;

      theta = flush_theta;

      columns[0] = 0;
      columns[1] = 0;
    end else begin
      wea_1 = write_enable & theta < ROTATIONAL_RES/2;
      wea_2 = write_enable & theta >= ROTATIONAL_RES/2;
      
      if (state == WRITING || new_data) begin
        theta = new_data ? theta_write: theta_pipe[1]; // Funky logic to get ahead by one clock cycle

        columns[0] = 0;
        columns[1] = 0;
      end else begin
        theta = theta_read;

        if (state == WAIT) begin
          columns[0] = 0;
          columns[1] = 0;
          
        end else if (theta_pipe[1] < ROTATIONAL_RES/2) begin
          columns[0] = row_1_out[DISPLAY_HEIGHT*DATA_SIZE-1:0];
          columns[1] = row_2_out[DISPLAY_HEIGHT*DATA_SIZE-1:0];

          radii[0] = row_1_out[COLUMN_DATA_WIDTH-1: COLUMN_DATA_WIDTH-$clog2(DISPLAY_RADIUS)];
          radii[1] = row_2_out[COLUMN_DATA_WIDTH-1: COLUMN_DATA_WIDTH-$clog2(DISPLAY_RADIUS)];
          
        end else begin
          columns[0] = row_2_out[DISPLAY_HEIGHT*DATA_SIZE-1:0];
          columns[1] = row_1_out[DISPLAY_HEIGHT*DATA_SIZE-1:0];
          
          radii[0] = row_2_out[COLUMN_DATA_WIDTH-1: COLUMN_DATA_WIDTH-$clog2(DISPLAY_RADIUS)];
          radii[1] = row_1_out[COLUMN_DATA_WIDTH-1: COLUMN_DATA_WIDTH-$clog2(DISPLAY_RADIUS)];
        end

        // columns[0] = theta_pipe[1] < ROTATIONAL_RES/2 ? row_1_out[DISPLAY_HEIGHT*DATA_SIZE-1:0] : 
        //                                               row_2_out[DISPLAY_HEIGHT*DATA_SIZE-1:0];
        // columns[1] = theta_pipe[1] < ROTATIONAL_RES/2 ? row_2_out[DISPLAY_HEIGHT*DATA_SIZE-1:0] :
                                                      // row_1_out[DISPLAY_HEIGHT*DATA_SIZE-1:0];
      end
    end

    
    // addr_theta = theta > ROTATIONAL_RES/2 ? theta - ROTATIONAL_RES/2 : theta;
    if (theta > ROTATIONAL_RES/2) begin
      addr_theta = theta - ROTATIONAL_RES/2;
    end else begin
      addr_theta = theta;
    end

  end
  logic timer;

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      state <= IDLE;
      theta <= 0;
    end else begin
      theta_pipe[0] <= theta;
      theta_pipe[1] <= theta_pipe[0];

      case (state)
        IDLE: begin

          write_enable <= 0;
          
          if (flush) begin
            state <= FLUSHING;
            flush_theta <= 0;
            new_column <= 0;

          end else if (new_data) begin
            state <= WRITING;
            timer <= 0;

          end
        end
        FLUSHING: begin

          flush_theta <= flush_theta + 1;

          if (flush_theta == ROTATIONAL_RES/2 -1) begin
            timer <= 0;
            state <= WAIT;
          end
        end
        WRITING: begin

          timer <= timer + 1;

          if (timer == 1) begin
            
            new_column <= current_column | old_column[DISPLAY_HEIGHT*DATA_SIZE-1:0];
            write_enable <= 1;
            timer <= 0;
            state <= WAIT;
          end

        end
        WAIT: begin

          timer <= timer + 1;
          write_enable <= 0;

          if (timer == 1) begin
            state <= IDLE;
          end
          
        end
      endcase
    end
  end


endmodule
`default_nettype none
module boids #(
    parameter MAX_DISTANCE = 32,
    parameter RANGE = 64,
    parameter NUM_BOIDS = 24
)
  (
    logic rst_in,
    logic clk_in,
    logic b_clk_in,
    logic initialize_rand
  );

  typedef enum { IDLE,
                INITIALIZE,
                FIND_NEIGHBORS_AND_COHESION,
                ALIGN,
                // COHESION,
                SEPARATION,
                UPDATE } BOID_STATE;


  BOID_STATE state;
  logic [NUM_BOIDS-1:0] boids_influenced;
  logic [$clog2(NUM_BOIDS)-1:0] boid_id;

  distance_3d #(
    .MAX_DISTANCE(MAX_DISTANCE),
    .RANGE(RANGE)
  ) distance_3d_inst (
    .rst_in(rst_in),
    .clk_in(clk_in),
    .x1_in(x1_in),
    .y1_in(y1_in),
    .z1_in(z1_in),
    .x2_in(x2_in),
    .y2_in(y2_in),
    .z2_in(z2_in),
    .new_data(new_data),
    .distance(distance),
    .data_ready(data_ready),
    .exceeded(exceeded)
  );




  // xilinx_single_port_ram_read_first #(
  //       .RAM_WIDTH(8*3),                       // Specify RAM data width
  //       .RAM_DEPTH(NUM_BOIDS),                     // Specify RAM depth (number of entries)
  //       .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
  //       .INIT_FILE(`FPATH(arctan2.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
  //   ) boid_pos (
  //       .addra(arctan_addr),     // Address bus, width determined from RAM_DEPTH
  //       .dina(1'b0),       // RAM input data, width determined from RAM_WIDTH
  //       .clka(clk_in),       // Clock
  //       .wea(1'b0),         // Write enable
  //       .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
  //       .rsta(rst_in),       // Output reset (does not affect memory contents)
  //       .regcea(1'b1),   // Output register enable
  //       .douta(theta)      // RAM output data, width determined from RAM_WIDTH
  //   );

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      state <= IDLE;
    end else begin
      case(state)
        IDLE: begin


          if(initialize_rand) begin
            state <= INITIALIZE;
          end
        end
        INITIALIZE: begin

          state <= FIND_NEIGHBORS_AND_COHESION;
        end
        FIND_NEIGHBORS_AND_COHESION: begin

          state <= ALIGN;
        end
        ALIGN: begin
          
          state <= SEPARATION;
        end
        SEPARATION: begin
          
          state <= UPDATE;
        end
        UPDATE: begin


          if (boid_id == NUM_BOIDS-1) begin
            state <= IDLE;
          end else begin
            boid_id <= boid_id + 1;
            state <= FIND_NEIGHBORS_AND_COHESION;
          end
        end
      endcase
    end
  end


endmodule
module rot_frame_buffer_to_hub75
#( parameter ROTATIONAL_RES = 1024,
  parameter SCAN_RATE = 32,
  parameter DISPLAY_HEIGHT = 64,
  parameter NUM_ROWS=64,
  parameter DATA_SIZE = 1,
  parameter RGB_RES=9

) (
    input wire rst_in,
    input wire clk_in,

    input wire hub75_ready,
    input wire hub75_last,

    input wire [1:0][$clog2(SCAN_RATE)-1:0] radii_input,
    input wire [1:0][NUM_ROWS-1:0] rfb_cols_input,

    input wire [$clog2(ROTATIONAL_RES)-1:0] theta,

    output logic [$clog2(SCAN_RATE)-1:0] col_num,
    output logic [1:0][NUM_ROWS-1:0][RGB_RES-1:0] columns,
    output logic data_valid



);

    logic [1:0][$clog2(SCAN_RATE)-1:0] radii;

    logic [1:0][NUM_ROWS-1:0][RGB_RES-1:0] input_cols;
    logic [NUM_ROWS-1:0][RGB_RES-1:0] column0;
    logic [NUM_ROWS-1:0][RGB_RES-1:0] column1;

    logic [$clog2(SCAN_RATE)-1:0] current_col_num;
    logic [NUM_ROWS-1:0][RGB_RES-1:0]  zero_column;

    logic [2:0] theta_top_bits;

    assign theta_top_bits = theta[$clog2(ROTATIONAL_RES)-1: $clog2(ROTATIONAL_RES)-3];

    typedef enum { IDLE, WRITING_COLUMN0, WRITING_COLUMN1 } rfb_to_hub_state;
  
    rfb_to_hub_state state;
    

    always_comb begin //TAKE INPUT IN FROM RFB AND MAKE COMPATIBLE WITH 

        for(int i = 0; i<64; i++) begin
            zero_column[i] = {RGB_RES{1'b0}};
            if (rfb_cols_input[0][i]) begin 
                input_cols[0][i] = {RGB_RES{1'b1}};

            end
            else begin
                input_cols[0][i] = {RGB_RES{1'b0}};
                
            end

            if (rfb_cols_input[1][i]) begin
                input_cols[1][i] = {RGB_RES{1'b1}};
                //input_cols[1][i] = {  1'b0, theta };
            end
            else begin
                input_cols[1][i] = {RGB_RES{1'b0}};
            end 
            
        end
    end

    always_ff @(posedge clk_in) begin

        if(rst_in) begin
            state <= IDLE;
            col_num <= 0;
            columns <= 0;
        end
        else begin

            if(state == IDLE) begin
                radii <= radii_input;
                column0 <= input_cols[0];
                column1 <= input_cols[1];

                if(hub75_last) begin
                    state <= WRITING_COLUMN0;
                end

            end
            else if (state == WRITING_COLUMN0) begin
                columns[0] <= zero_column;
                columns[1] <= column0;
                col_num <= radii[0];
                data_valid <= 1;
                

                if(hub75_last) begin
                    state <= WRITING_COLUMN1;
                end


            end

            else if (state == WRITING_COLUMN1) begin
                columns[0] <= column1;
                columns[1] <= zero_column;
                col_num <= 31 -  radii[1];
                state <= IDLE;


            end
        end
    end


endmodule
`default_nettype none

`default_nettype none
module hub75_output #(
    parameter ROTATIONAL_RES=1024,
    parameter NUM_COLS=64,
    parameter NUM_ROWS=64,
    parameter SCAN_RATE=32,
    parameter THETA_RES=8,
    parameter PERIOD=10, //set to be a function of theta in the future
    parameter RGB_RES=9
)
 (
    input wire rst_in,
    input wire clk_in,
    //TODO: add second clk and change module to take multiple clocks
    input wire [1:0][NUM_ROWS-1:0][RGB_RES-1:0] column_data,
    //input wire [NUM_ROWS-1:0][RGB_RES:0] column_data1,
    input wire [$clog2(SCAN_RATE)-1:0] address_data,

    
    output logic [2:0] rgb0,
    output logic [2:0] rgb1,

    output logic led_latch, 
    output logic led_clk,
    output logic led_output_enable,
    output logic [$clog2(SCAN_RATE)-1:0] hub75_address,

    //AXI Stream logic
    input wire   tvalid,
    output logic tready,
    output logic tlast
);

   logic [$clog2(NUM_COLS)-1:0] pixel_counter;
   logic [$clog2(ROTATIONAL_RES)-1:0] period_counter;
   logic [2:0] state;
   logic [1:0] pwm_counter; 

   logic clk_msk; 
   logic [1:0][NUM_ROWS-1:0][RGB_RES-1:0] columns;
   assign led_clk = clk_in & clk_msk; //control the hub75 clk input with the clk_msk  

   assign tready = state == 0;
    assign tlast = period_counter == PERIOD * (pwm_counter + 1) - 1 && pwm_counter == 2;
    

   initial begin 
    state = 0;
    pixel_counter = 0; 
    clk_msk = 0;
    period_counter = 0;

   end

   always_comb begin
        


    if(pwm_counter == 0) begin

            rgb0[0] = columns[0][pixel_counter][0];
            rgb0[1] = columns[0][pixel_counter][3];
            rgb0[2] = columns[0][pixel_counter][6];

            rgb1[0] = columns[1][pixel_counter][0];
            rgb1[1] = columns[1][pixel_counter][3];
            rgb1[2] = columns[1][pixel_counter][6];


        end
        else if(pwm_counter == 1) begin
            rgb0[0] = columns[0][pixel_counter][1] ;
            rgb0[1] = columns[0][pixel_counter][4];
            rgb0[2] = columns[0][pixel_counter][7];

            rgb1[0] = columns[1][pixel_counter][1];
            rgb1[1] = columns[1][pixel_counter][4];
            rgb1[2] = columns[1][pixel_counter][7];
        end
        else if(pwm_counter == 2) begin
            rgb0[0] = columns[0][pixel_counter][2] ;
            rgb0[1] = columns[0][pixel_counter][5];
            rgb0[2] = columns[0][pixel_counter][8];

            rgb1[0] = columns[1][pixel_counter][2];
            rgb1[1] = columns[1][pixel_counter][5];
            rgb1[2] = columns[1][pixel_counter][8];
        end
   end

   always_ff @(posedge clk_in) begin
    if(rst_in) begin
        state <= 0;
        pixel_counter <= 0 ;
        clk_msk <= 0;
        period_counter <= 0;

    end
    else if(state == 0) begin //initing
        
        if(tvalid) begin
            state <= 1;
            columns <= column_data;
            clk_msk <= 1;
            led_output_enable <= 1;
            period_counter <= 0;
            pwm_counter <= 0;
            pixel_counter <= 0;
            led_latch <= 0;
            hub75_address <= address_data;
        end
    end
    else if(state == 1) begin //BCM

        led_output_enable <= 1;
        

        /*if(pixel_counter[0] & 8'b0000001) begin
            rgb0[0] <= 1;
            rgb0[1] <= 1;
            rgb0[2] <= 0;

            rgb1[0] <= 0;
            rgb1[1] <= 1;
            rgb1[2] <= 1;
        end 
        else begin 
            rgb0[0] <= 0;
            rgb0[1] <= 0;
            rgb0[2] <= 0;

            rgb1[0] <= 0;
            rgb1[1] <= 0;
            rgb1[2] <= 0;
        end*/

        if(pixel_counter == 63 ) begin
            state <= 2;
            clk_msk <= 0;
            led_latch <=1;
            led_output_enable <= 0;
        end
        else begin
            pixel_counter <= pixel_counter + 1;
        end
    end
    else if(state == 2) begin //WAITING PERIOID
    
        led_latch <= 0;

        period_counter <= period_counter+ 1;
        if(period_counter == PERIOD * (pwm_counter + 1) - 1 ) begin
            period_counter <= 0;
            if(pwm_counter == 2) begin
                state <= 0;
                
            end
            else begin 
                pwm_counter <= pwm_counter + 1;
                state <= 1;
            end
        end
    end

   

   end
endmodule
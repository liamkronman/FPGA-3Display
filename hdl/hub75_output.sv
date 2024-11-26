
`default_nettype none
module hub75_output #(
    parameter ROTATIONAL_RES=180,
    parameter NUM_COLS=64,
    parameter NUM_ROWS=64,
    parameter SCAN_RATE=32,
    parameter THETA_RES=8,
    parameter PERIOD = 100 //set to be a function of theta in the future
)
 (
    input wire rst_in,
    input wire clk_in,
    input wire [8:0][63:0] column_data0,
    input wire [8:0][63:0] column_data1,
    input wire [$clog2(SCAN_RATE)-1:0] col_index,
    
    output logic [2:0] rgb0,
    output logic [2:0] rgb1,

    output logic led_latch, 
    output logic led_clk,
    output logic led_output_enable,

    //AXI Stream logic
    input wire         tvalid,
    output logic         tready
);

   logic [5:0] pixel_counter;
   logic [10:0] period_counter;
   logic [2:0] state;
   logic [1:0] pwm_counter; 

   logic clk_msk; 
   logic [NUM_ROWS-1:0][8:0] column0;
   logic [NUM_ROWS - 1: 0][8:0] column1;
   assign led_clk = clk_in & clk_msk; //control the hub75 clk input with the clk_msk  

   assign tready = state == 0;
    
   /*always_comb begin
    if(pwm_counter == 0) begin

        rgb0[0] = column0[pixel_counter][0] ;
        rgb0[1] = column0[pixel_counter][0];
        rgb0[2] = column0[pixel_counter][0];

        rgb1[0] = column1[pixel_counter][0];
        rgb1[1] = column1[pixel_counter][0];
        rgb1[2] = column1[pixel_counter][0];


    end
    else if(pwm_counter == 1) begin
        rgb0[0] = column0[pixel_counter][0] ;
        rgb0[1] = column0[pixel_counter][3];
        rgb0[2] = column0[pixel_counter][6];

        rgb1[0] = column1[pixel_counter][0];
        rgb1[1] = column1[pixel_counter][3];
        rgb1[2] = column1[pixel_counter][6];
    end
    else if(pwm_counter == 2) begin
        rgb0[0] = column0[pixel_counter][0] ;
        rgb0[1] = column0[pixel_counter][3];
        rgb0[2] = column0[pixel_counter][6];

        rgb1[0] = column1[pixel_counter][0];
        rgb1[1] = column1[pixel_counter][3];
        rgb1[2] = column1[pixel_counter][6];
    end
    


   end*/

   always_ff @(posedge clk_in) begin
    if(rst_in) begin
        state <= 0;
        pixel_counter <= 0 ;
        clk_msk <= 0;
        period_counter <= 0;
    end
    else if(state == 0) begin //initing
        led_output_enable <= 1;
        
        pwm_counter <= 0;
        pixel_counter <= 0;
        led_latch <= 0;
        clk_msk <= 1;
        period_counter <= 0;

        if(tvalid) begin
            state <= 1;
            column0 <= column_data0;
            column1 <= column_data1;
        end


        
    
    end
    else if(state == 1) begin //BCM

        led_output_enable <= 1;
        rgb0[0] <=1;
        rgb0[1] <=1;
        rgb0[2] <=1;

        rgb1[0] <=1;
        rgb1[1] <=1;
        rgb1[2] <=1;


        
        
        if(pixel_counter == 63 ) begin
            state <= 2;
            clk_msk <= 0;
            led_latch <=1;
        end
        else begin
            pixel_counter <= pixel_counter + 1;
        end
    end
    else if(state == 2) begin //WAITING PERIOID
    led_output_enable <= 0;
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
module hub75_output #(
    parameter ROTATIONAL_RES=180,
    parameter NUM_COLS=64,
    parameter NUM_ROWS=64,
    parameter SCAN_RATE=32,
    parameter THETA_RES=8
)
 (
    input wire rst_in,
    input wire clk_in,
    input wire [1:0][NUM_ROWS-1:0][8:0] columns,
    input wire [$clog2(SCAN_RATE)-1:0] col_index,
    
    output logic rgb0[2:0],
    output logic rgb1[2:0],

    output logic led_latch, 
    output logic led_clk,
    output logic led_output_enable
);

   logic [5:0] pixel_counter;
   logic [5:0] period_counter;
   logic [2:0] state
   logic [2:0] pwm_counter; 

   logic clk_msk; 
   assign led_clk = clk_in & clk_msk; //control the hub75 clk input with the clk_msk  

   always_ff @(posedge clk_in) begin
    if(rst_in) begin
        state <= 0;
        pixel_counter <= 0 ;
        clk_msk <= 0;
    end
    else if(state == 0) begin //initing
        led_output_enable <= 1;
        state <= 1;
        pwm_counter <= 0;
        pixel_counter <= 0;


        
    
    end
    else if(state == 1) begin //BCM

        led_output_enable <= 1;
        rgb0[0] <= rows[0][pixel_counter][0 + pwm_counter];
        rgb0[1] <= rows[0][pixel_counter][3 + pwm_counter];
        rgb0[2] <= rows[0][pixel_counter][6 + pwm_counter];

        rgb1[0] <= rows[1][pixel_counter][0 + pwm_counter];
        rgb1[1] <= rows[1][pixel_counter][3 + pwm_counter];
        rgb1[2] <= rows[1][pixel_counter][6 + pwm_counter];
        
        if(pixel_counter == 63 ) begin
            state <= 2;
        end
        else begin
            pixel_counter <= pixel_counter + 1;
        end





    end
    else if(state == 2) begin //WAITING PERIOID


    end

   end
endmodule
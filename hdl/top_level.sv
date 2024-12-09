
`default_nettype none
module top_level #(
    parameter ROTATIONAL_RES=1024,
    parameter NUM_COLS=64,
    parameter NUM_ROWS=64,
    parameter SCAN_RATE=32,
    parameter RGB_RES=9
)
(
    input wire clk_12mhz, // 12MHz clock (from CMOD A7)
    input wire ir_tripped, // PMOD pin 1
    output logic [1:0] led, // LED outputs,
    output logic [4:0] hub75_addr,
    output logic [2:0] hub75_rgb0,
    output logic [2:0] hub75_rgb1,
    output logic hub75_latch,
    output logic hub75_OE, 
    output logic hub75_clk,
    input wire [1:0] btn
);

    //Handling creating and assigning different clocks
    logic clk_100mhz;
    logic clk_24mhz;
    logic clk_12mhz_passthrough;
    
    BUFG sys_clk_buf
   (.O (clk_12mhz_passthrough),
    .I (clk_12mhz));
    clk_wiz clock_wizard
    (.sysclk(clk_12mhz_passthrough),
    .clk_100mhz(clk_100mhz),
    .clk_24mhz(clk_24mhz),
    .reset(0));

    logic sysclk;
    logic sys_rst;

    always_comb begin
        sysclk = clk_24mhz;
    end

    //assign sysclk = clk_12mhz;

    assign sys_rst = btn[0];

    logic debounced_ir_tripped;
 
    debouncer ir_tripped_db(.clk_in(sysclk),
                    .rst_in(sys_rst),
                    .dirty_in(ir_tripped),
                    .clean_out(debounced_ir_tripped));
    
    // tie led0 to ir_led_control and led1 to low
    ir_led_control ilc(
        .ir_tripped(ir_tripped),
        .led_out(led[0])
    );
    assign led[1] = 0;

    //TODO: CREATE 100 Mhz clock

    //TODO: Create 20 MHZ clock
    
    
    logic [$clog2(ROTATIONAL_RES)-1:0] dtheta;
    logic [1:0][NUM_ROWS-1:0][RGB_RES-1:0] columns;

    logic [$clog2(SCAN_RATE)-1:0] col_num1;
    logic [$clog2(SCAN_RATE)-1:0] col_num2;


    logic hub75_ready;
    logic hub75_data_valid;
    detect_to_theta dt (
        .ir_tripped(ir_tripped),
        .clk_in(sysclk),
        .rst_in(sys_rst),
        .dtheta(dtheta)
    );

    frame_manager fm (
        .clk_in(sysclk), // use a different clock?
        .rst_in(sys_rst),
        .mode(2'b10), // hard-coded to SPHERE mode for now
        .dtheta(dtheta),
        .columns(columns),

        .col_num1(col_num1),
        .col_num2(col_num2),
        .hub75_ready(hub75_ready),
        .data_valid(hub75_data_valid)
    );


  
    

    hub75_output hub75 (
        .clk_in(sysclk), // use a different clock?
        .rst_in(sys_rst),
        .column_data(columns),
        .tvalid(hub75_data_valid),
        .tready(hub75_ready),
        .address_data(dtheta),
        .rgb0(hub75_rgb0),
        .rgb1(hub75_rgb1),
        .led_latch(hub75_latch),
        .led_output_enable(hub75_OE),
        .hub75_address(hub75_addr),
        
        .led_clk(hub75_clk)
    );
    // always_ff @(posedge sysclk) begin  
    //     if(hub75_ready == 1) begin
    //         hub75_addr <= hub75_addr + 1;
    //     end
    // end
endmodule

`default_nettype none
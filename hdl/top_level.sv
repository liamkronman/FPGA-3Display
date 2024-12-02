
`default_nettype none
module top_level #(
    parameter ROTATIONAL_RES=256,
    parameter NUM_COLS=64,
    parameter NUM_ROWS=64,
    parameter SCAN_RATE=32,
    parameter RGB_RES=9
)
(
    input wire sysclk, // 12MHz clock (from CMOD A7)
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
    logic sys_rst;
    assign sys_rst = btn[0];
    // tie led0 to ir_led_control and led1 to low
    ir_led_control ilc(
        .ir_tripped(ir_tripped),
        .led_out(led[0])
    );
    assign led[1] = 0;

    //TODO: CREATE 100 Mhz clock

    //TODO: Create 20 MHZ clock
    

<<<<<<< HEAD
    logic [THETA_RES-1:0] theta;
    logic period_ready;
    logic [THETA_RES-1:0] period;
    logic [1:0][NUM_ROWS-1:0][RGB_RES-1:0] columns;

=======
    logic [$clog2(ROTATIONAL_RES)-1:0] dtheta;
    logic [$clog2(NUM_ROWS)-1:0][RGB_RES-1:0] column0;
    logic [$clog2(NUM_ROWS)-1:0][RGB_RES-1:0] column1;
>>>>>>> refs/remotes/origin/main
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
        .rst_in(0),
        .mode(2'b01), // hard-coded to SPHERE mode for now
<<<<<<< HEAD
        .theta(theta),
        .period_ready(period_ready),
        .period(period),
        .columns(columns),
=======
        .dtheta(dtheta),
        .columns({column0, column1}),
>>>>>>> refs/remotes/origin/main
        .col_num1(col_num1),
        .col_num2(col_num2),
        .hub75_ready(hub75_ready),
        .data_valid(hub75_data_valid)
    );

    always_comb begin
        hub75_addr = col_num1;
    end
    

    hub75_output hub75 (
        .clk_in(sysclk), // use a different clock?
        .rst_in(sys_rst),
        .col_index(20),
        .column_data(columns),
        .tvalid(1),
        .tready(hub75_ready),

        .rgb0(hub75_rgb0),
        .rgb1(hub75_rgb1),
        .led_latch(hub75_latch),
        .led_output_enable(hub75_OE),
        .led_clk(hub75_clk)
    );
    // always_ff @(posedge sysclk) begin  
    //     if(hub75_ready == 1) begin
    //         hub75_addr <= hub75_addr + 1;
    //     end
    // end
endmodule

`default_nettype none
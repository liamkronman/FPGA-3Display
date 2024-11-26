
`default_nettype none
module top_level #(
    parameter ROTATIONAL_RES=180,
    parameter NUM_COLS=64,
    parameter NUM_ROWS=64,
    parameter SCAN_RATE=32,
    parameter THETA_RES=27,
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
    output logic hub75_clk
);
    logic sys_rst;
    assign sys_rst = 0;
    // tie led0 to ir_led_control and led1 to low
    ir_led_control ilc(
        .ir_tripped(ir_tripped),
        .led_out(led[0])
    );
    assign led[1] = 0;

    //TODO: CREATE 100 Mhz clock

    //TODO: Create 20 MHZ clock
    assign hub75_addr = 16;

    logic [THETA_RES-1:0] theta;
    logic period_ready;
    logic [THETA_RES-1:0] period;
    logic [1:0][$clog2(NUM_ROWS)-1:0][RGB_RES-1:0] columns;
    logic [$clog2(SCAN_RATE)-1:0] col_num1;
    logic [$clog2(SCAN_RATE)-1:0] col_num2;

    detect_to_theta dt (
        .ir_tripped(ir_tripped),
        .clk_in(sysclk),
        .rst_in(sys_rst),
        .theta(theta),
        .period_ready(period_ready),
        .period(period)
    );

    frame_manager fm (
        .clk_in(sysclk),
        .rst_in(sys_rst),
        .mode(2'b01), // hard-coded to SPHERE mode for now
        .theta(theta),
        .columns(columns),
        .col_num1(col_num1),
        .col_num2(col_num2)
    );

    hub75_output hub75 (
        .clk_in(sysclk),
        .rst_in(sys_rst),
        .col_index(hub75_addr),
        .rgb0(hub75_rgb0),
        .rgb1(hub75_rgb1),
        .led_latch(hub75_latch),
        .led_output_enable(hub75_OE),
        .led_clk(hub75_clk)
    );


endmodule

`default_nettype none
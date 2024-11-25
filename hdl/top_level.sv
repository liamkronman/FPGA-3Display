`default_nettype none
module top_level
(
    input wire sysclk, // 12MHz clock (from CMOD A7)
    input wire ir_tripped, // PMOD pin 1
    output logic [1:0] led // LED outputs
);
    // tie led0 to ir_led_control and led1 to low
    ir_led_control ilc(
        .ir_tripped(ir_tripped),
        .led_out(led[0])
    );
    assign led[1] = 0;
endmodule
`default_nettype none
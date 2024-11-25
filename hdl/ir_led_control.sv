module ir_led_control (
    input wire ir_tripped,  // Input from IR sensor
    output logic led_out    // Output to LED
);
    always_comb begin
        led_out = ir_tripped; // Drive LED with IR sensor signal
    end
endmodule
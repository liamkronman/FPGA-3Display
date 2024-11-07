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
    input wire [1:0][$clog2(NUM_ROWS)-1:0] columns,
    input wire [$clog2(SCAN_RATE)-1:0] col_num1,
    input wire [$clog2(SCAN_RATE)-1:0] col_num2,
    // TODO: nathaniel works on the outputs (A,B,C,D,E,latch,clk,etc.)
);
endmodule
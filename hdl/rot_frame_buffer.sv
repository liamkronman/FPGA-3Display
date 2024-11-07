module rot_frame_buffer
#( parameter ROTATIONAL_RES = 32)
(
    input wire rst_in,
    input wire clk_in,
    input wire new_data,
    input wire [7:0] theta,
    input wire [7:0] radius,
    input wire [7:0] y,

    input wire [$clog2(64*ROTATIONAL_RES)-1:0] addr_in,

    output logic data_ready,
    output logic [63:0] row_out
);


    always_ff @(posedge clk_in) begin
        if (~rst_in) begin
            if (new_data) begin
                data_ready <= 1;
            end else begin
                data_ready <= 0;
            end
        end
    end


endmodule
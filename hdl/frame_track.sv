module frame_track
(
    input wire rst_in,
    input wire mode,
    input wire clk_in,
    input wire [7:0] theta, // suppose 8 bit resolution for theta
    output logic [127:0][63:0][11:0] frame // JOE WILL NOT LIKE THIS PARALLELISM
    output logic ready,
);
    cube_frame cf (
        .theta(theta),
        .frame(cube_f)
    );
    boids_lookup bf (
        .theta(theta),
        .frame(boids_f)
    );
    always_ff @(posedge clk_in) begin
        if (~rst_in) begin
            if (mode) begin // cube mode
                frame => cube_f;
            end else begin // boids mode
                frame => boids_f;
            end
        end
    end
endmodule
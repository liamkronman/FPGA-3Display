`default_nettype none
module evt_counter #(MAX_COUNT = 134217728)
  ( input wire          clk_in,
    input wire          rst_in,
    input wire          evt_in,
    output logic[26:0]  count_out
  );
 
  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      count_out <= 27'b0;
    end else begin
      if (evt_in) begin
        if (count_out == MAX_COUNT-1) begin
          count_out <= 27'b0;
        end else begin
          count_out <= count_out + 1;
        end
      end
    end
  end
endmodule
`default_nettype wire
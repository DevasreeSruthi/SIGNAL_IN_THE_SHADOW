module adaptive_threshold #(
    parameter DATA_W = 8
)(
    input  logic              clk,
    input  logic              rst_n,
    input  logic [DATA_W-1:0] noise_level,
    input  logic [DATA_W-1:0] base_threshold,
    input  logic              valid_in,
    output logic [DATA_W-1:0] threshold_out
);

    logic [DATA_W+1:0] noise_contribution;
    logic [DATA_W+1:0] base_extended;
    logic [DATA_W+1:0] threshold_calc;
    logic [DATA_W+1:0] max_noise_contribution;

    always @* begin
        base_extended = {{2{1'b0}}, base_threshold};

        max_noise_contribution = base_extended >> 1;

        noise_contribution =
            {{2{1'b0}}, noise_level} << 1;

        if (noise_contribution > max_noise_contribution)
            noise_contribution = max_noise_contribution;

        threshold_calc = base_extended + noise_contribution;
    end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        threshold_out <= {DATA_W{1'b0}};
    else if (valid_in) begin
            if (threshold_calc > ((1 << DATA_W) - 1))
                threshold_out <= {DATA_W{1'b1}};
            else
                threshold_out <= threshold_calc[DATA_W-1:0];
        end
    end

endmodule

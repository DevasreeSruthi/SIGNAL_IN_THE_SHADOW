module noise_estimator #(
    parameter DATA_W = 8
)(
    input  logic              clk,
    input  logic              rst_n,
    input  logic              valid_in,
    input  logic [DATA_W-1:0] sample_in,
    output logic [DATA_W-1:0] noise_level
);

    logic [DATA_W-1:0] previous_sample;
    logic [DATA_W-1:0] difference;
    logic signed [DATA_W:0] signed_difference;
    logic signed [DATA_W:0] absolute_difference;
    logic              sample_initialized;

    always @* begin
        signed_difference =
            $signed({1'b0, sample_in}) -
            $signed({1'b0, previous_sample});

        if (signed_difference < 0)
            absolute_difference = -signed_difference;
        else
            absolute_difference = signed_difference;

        difference = absolute_difference[DATA_W-1:0];
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            previous_sample    <= '0;
            noise_level        <= '0;
            sample_initialized <= 1'b0;
        end
        else if (valid_in) begin
            previous_sample <= sample_in;

            if (!sample_initialized) begin
                noise_level        <= '0;
                sample_initialized <= 1'b1;
            end
            else if (difference > noise_level) begin
                noise_level <= noise_level +
                               ((difference - noise_level) >> 2);
            end
            else begin
                noise_level <= noise_level -
                               ((noise_level - difference) >> 2);
            end
        end
    end

endmodule

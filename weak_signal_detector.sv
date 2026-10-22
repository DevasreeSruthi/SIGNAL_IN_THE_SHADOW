module weak_signal_detector #(
    parameter DATA_W = 8
)(
    input  logic              clk,
    input  logic              rst_n,
    input  logic [DATA_W-1:0] sample_in,
    input  logic [DATA_W-1:0] background_in,
    input  logic [DATA_W-1:0] threshold_in,
    input  logic              valid_in,

    output logic              signal_detected,
    output logic [DATA_W-1:0] signal_magnitude,
    output logic              valid_out
);

    logic [DATA_W-1:0] difference;

    always @* begin
        if (sample_in >= background_in)
            difference = sample_in - background_in;
        else
            difference = background_in - sample_in;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            signal_detected  <= 1'b0;
            signal_magnitude <= '0;
            valid_out        <= 1'b0;
        end
        else begin
            valid_out <= valid_in;

            if (valid_in) begin
                signal_magnitude <= difference;
                signal_detected  <= (difference >= threshold_in);
            end
            else begin
                signal_magnitude <= '0;
                signal_detected  <= 1'b0;
            end
        end
    end

endmodule

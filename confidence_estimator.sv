module confidence_estimator #(
    parameter DATA_W = 8
)(
    input  logic [DATA_W-1:0] magnitude_in,
    input  logic [DATA_W-1:0] threshold_in,
    input  logic              persistent_in,
    input  logic              valid_in,
    output logic [7:0]        confidence
);

    logic [DATA_W:0] margin;

    always @* begin
        if (magnitude_in > threshold_in)
            margin = magnitude_in - threshold_in;
        else
            margin = '0;

        if (!valid_in)
            confidence = 8'd0;
        else if (!persistent_in)
            confidence = margin[DATA_W-1:0] >> 1;
        else begin
            if (margin >= 8'd127)
                confidence = 8'd255;
            else
                confidence = margin[7:0] << 1;
        end
    end

endmodule

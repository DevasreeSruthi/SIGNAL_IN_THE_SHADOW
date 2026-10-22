module signal_in_the_shadow_top #(
    parameter DATA_W  = 8,
    parameter COUNT_W = 3
)(
    input  logic               clk,
    input  logic               rst_n,
    input  logic [DATA_W-1:0]  radar_sample,
    input  logic [DATA_W-1:0]  background_level,
    input  logic [DATA_W-1:0]  base_threshold,
    input  logic [COUNT_W-1:0] required_persistence,
    input  logic               valid_in,

    output logic               target_detected,
    output logic [DATA_W-1:0]  signal_magnitude,
    output logic [DATA_W-1:0]  estimated_noise,
    output logic [DATA_W-1:0]  adaptive_threshold,
    output logic [7:0]         confidence,
    output logic               valid_out
);

    logic detector_event;
    logic detector_valid;
    logic persistent_event;

    logic [DATA_W-1:0] magnitude_for_confidence;
    logic [DATA_W-1:0] threshold_for_confidence;
    logic confidence_valid;
    logic [7:0] confidence_internal;

    noise_estimator #(
        .DATA_W(DATA_W)
    ) noise_unit (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .sample_in(radar_sample),
        .noise_level(estimated_noise)
    );

    adaptive_threshold #(
        .DATA_W(DATA_W)
    ) threshold_unit (
        .clk(clk),
        .rst_n(rst_n),
        .noise_level(estimated_noise),
        .base_threshold(base_threshold),
        .valid_in(valid_in),
        .threshold_out(adaptive_threshold)
    );

    weak_signal_detector #(
        .DATA_W(DATA_W)
    ) detector_unit (
        .clk(clk),
        .rst_n(rst_n),
        .sample_in(radar_sample),
        .background_in(background_level),
        .threshold_in(adaptive_threshold),
        .valid_in(valid_in),
        .signal_detected(detector_event),
        .signal_magnitude(signal_magnitude),
        .valid_out(detector_valid)
    );

    persistence_filter #(
        .COUNT_W(COUNT_W)
    ) persistence_unit (
        .clk(clk),
        .rst_n(rst_n),
        .event_in(detector_event),
        .valid_in(detector_valid),
        .required_count(required_persistence),
        .persistent_event(persistent_event)
    );

    // Keep the magnitude and threshold associated with
    // the detector output for the confidence calculation.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            magnitude_for_confidence <= '0;
            threshold_for_confidence <= '0;
            confidence_valid         <= 1'b0;
        end
        else begin
            confidence_valid <= detector_valid;

            if (detector_valid) begin
                magnitude_for_confidence <= signal_magnitude;
                threshold_for_confidence <= adaptive_threshold;
            end
        end
    end

    confidence_estimator #(
        .DATA_W(DATA_W)
    ) confidence_unit (
        .magnitude_in(magnitude_for_confidence),
        .threshold_in(threshold_for_confidence),
        .persistent_in(persistent_event),
        .valid_in(confidence_valid),
        .confidence(confidence_internal)
    );

    assign target_detected = persistent_event;
    assign valid_out       = detector_valid;
    assign confidence      = confidence_internal;

endmodule

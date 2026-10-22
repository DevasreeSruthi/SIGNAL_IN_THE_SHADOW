module persistence_filter #(

    parameter COUNT_W = 3

)(

    input  logic               clk,

    input  logic               rst_n,

    input  logic               event_in,

    input  logic               valid_in,

    input  logic [COUNT_W-1:0] required_count,

    output logic               persistent_event

);



    logic [COUNT_W-1:0] count;

    logic [COUNT_W:0] next_count;



    always @* begin

        next_count = {1'b0, count} + 1'b1;

    end



    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            count            <= '0;

            persistent_event <= 1'b0;

        end

        else if (!valid_in) begin

            count            <= '0;

            persistent_event <= 1'b0;

        end

        else if (!event_in) begin

            count            <= '0;

            persistent_event <= 1'b0;

        end

        else if (required_count == 0) begin

            count            <= '0;

            persistent_event <= 1'b1;

        end

        else if (next_count >= {1'b0, required_count}) begin

            count            <= required_count;

            persistent_event <= 1'b1;

        end

        else begin

            count            <= next_count[COUNT_W-1:0];

            persistent_event <= 1'b0;

        end

    end



endmodule

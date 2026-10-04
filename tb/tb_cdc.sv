import cdc::*;

module tb_cdc;

    //Stimulus generated inside master , this just exists to connect master and cdc bridge and generate clocks
    //Ideally test peripheral should be at this level too , but currently is instantiated by cdc bridge.

    logic clk_a, clk_b;
    logic rst_a, rst_b;

    request_t  req;
    logic      req_valid;
    logic      req_ready;

    response_t resp;
    logic      resp_valid;
    logic      resp_ready;

    master master_inst (
        .clk_a(clk_a),
        .rst_a(rst_a),

        .req(req),
        .req_valid(req_valid),
        .req_ready(req_ready),

        .resp(resp),
        .resp_valid(resp_valid),
        .resp_ready(resp_ready)
    );

    cdc_bridge bridge_inst (
        .clk_a(clk_a),
        .rst_a(rst_a),

        .clk_b(clk_b),
        .rst_b(rst_b),

        .req(req),
        .req_valid(req_valid),
        .req_ready(req_ready),

        .resp(resp),
        .resp_valid(resp_valid),
        .resp_ready(resp_ready)
    );

    initial begin
        clk_a = 0;
        forever #5 clk_a = ~clk_a;
    end

    initial begin
        clk_b = 0;
        forever #7 clk_b = ~clk_b;
    end

    initial begin
        rst_a = 1;
        rst_b = 1;

        #30;

        rst_a = 0;
        rst_b = 0;
    end

endmodule

import cdc::*;

module cdc_bridge (
    input logic clk_a,
    input logic rst_a,

    input logic clk_b,
    input logic rst_b,

    //Interface to master
    input  request_t req,
    input  logic     req_valid,
    output logic     req_ready,

    output response_t resp,
    output logic      resp_valid,
    input  logic      resp_ready
);

    //Signals for interface to peripheral
    request_t  p_req;
    logic      p_req_valid;
    logic      p_req_ready;

    response_t p_resp;
    logic      p_resp_valid;
    logic      p_resp_ready;

    //Request fifo
    async_fifo #(
        .WIDTH($bits(request_t))
    ) request_fifo (
        .wr_clk(clk_a),
        .wr_rst(rst_a),

        .wr_data (req),
        .wr_valid(req_valid),
        .wr_ready(req_ready),

        .rd_clk(clk_b),
        .rd_rst(rst_b),

        .rd_data (p_req),
        .rd_valid(p_req_valid),
        .rd_ready(p_req_ready)
    );

    //Response fifo
    async_fifo #(
        .WIDTH($bits(response_t))
    ) response_fifo (
        .wr_clk(clk_b),
        .wr_rst(rst_b),

        .wr_data (p_resp),
        .wr_valid(p_resp_valid),
        .wr_ready(p_resp_ready),

        .rd_clk(clk_a),
        .rd_rst(rst_a),

        .rd_data (resp),
        .rd_valid(resp_valid),
        .rd_ready(resp_ready)
    );

    peripheral p_inst (
        .clk_b(clk_b),
        .rst_b(rst_b),

        .p_req(p_req),
        .p_req_valid(p_req_valid),
        .p_req_ready(p_req_ready),

        .p_resp(p_resp),
        .p_resp_valid(p_resp_valid),
        .p_resp_ready(p_resp_ready)
    );
endmodule

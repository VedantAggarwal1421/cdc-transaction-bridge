module peripheral (
    input logic clk_b,
    input logic rst_b,

    input  request_t p_req,
    input  logic     p_req_valid,
    output logic     p_req_ready,

    output response_t p_resp,
    output logic      p_resp_valid,
    input  logic      p_resp_ready
);


endmodule

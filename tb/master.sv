import cdc::*;

module master (
    input logic clk_a,
    input logic rst_a,

    output request_t req,
    output logic     req_valid,
    input  logic     req_ready,

    input  response_t resp,
    input  logic      resp_valid,
    output logic      resp_ready
);
endmodule

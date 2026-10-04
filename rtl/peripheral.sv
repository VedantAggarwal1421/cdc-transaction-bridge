import cdc::*;

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

    //Simple memory map 
    //0x0000 ID 0xCDC00000  Read only
    //0x0004 Counter        Read only
    //0x0008 Scratch        Read Write
    //0x000C Scratch=0      Read only

    logic [31:0] id;
    assign id = 32'hCDC0_0000;
    logic [31:0] counter;
    logic [31:0] scratch;
    logic [31:0] status;
    assign status = {31'b0, (scratch == 32'b0)};

    assign p_req_ready = ~p_resp_valid;  //Ready to receive another request while no active response

    always @(posedge clk_b or posedge rst_b) begin
        if (rst_b) begin
            p_resp_valid <= 1'b0;
            p_resp       <= '0;
            scratch      <= 32'b0;
        end else begin

            if (p_resp_ready && p_resp_valid) begin  //Response Consumed
                p_resp_valid <= 1'b0;
            end

            if (p_req_ready && p_req_valid) begin

                p_resp_valid <= 1'b1;
                p_resp.error <= 1'b0;
                p_resp.rdata <= 32'b0;

                if (!p_req.write) begin  //Read request
                    case (p_req.addr)
                        32'h0000_0000: p_resp.rdata <= id;
                        32'h0000_0004: p_resp.rdata <= counter;
                        32'h0000_0008: p_resp.rdata <= scratch;
                        32'h0000_000C: p_resp.rdata <= status;
                        default:       p_resp.error <= 1'b1;
                    endcase
                end else begin  //Write request
                    if (p_req.addr == 32'h0000_0008) begin
                        scratch <= p_req.wdata;
                    end else begin
                        p_resp.error <= 1'b1;
                    end
                end

            end
        end
    end

    always @(posedge clk_b or posedge rst_b) begin
        if (rst_b) begin
            counter <= 32'b0;
        end else begin
            counter <= counter + 1'b1;
        end
    end

endmodule

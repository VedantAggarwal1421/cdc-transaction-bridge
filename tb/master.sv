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

    assign resp_ready = 1'b1;  //Can always receive a response

    localparam test_no = 100;  //No of tests

    response_t expected[$];

    task automatic read(input logic [31:0] addr);
        @(negedge clk_a);
        req_valid = 1'b1;
        req.write = 1'b0;
        req.addr  = addr;
        req.wdata = 32'b0;

        while (1) begin
            @(posedge clk_a);

            if (req_ready) begin
                $display("Read request made. ADDR: %0h, Time: %0t", addr, $time);
                break;
            end
        end

        @(negedge clk_a);
        req_valid = 1'b0;
    endtask

    task automatic write(input logic [31:0] addr, input logic [31:0] data);
        @(negedge clk_a);
        req_valid = 1'b1;
        req.write = 1'b1;
        req.addr  = addr;
        req.wdata = data;

        while (1) begin
            @(posedge clk_a);

            if (req_ready) begin
                $display("Write request made. ADDR: %0h, Data: %0h, Time: %0t", addr, data, $time);
                break;
            end
        end

        @(negedge clk_a);
        req_valid = 1'b0;
    endtask

    always @(posedge clk_a) begin
        if (!rst_a && resp_valid && resp_ready) begin
            if (resp != expected[0]) begin
                $fatal("RESPONSE MISMATCH: Expected Rdata=%0h  Error=%b | Got Rdata=%0h  Error=%b",
                       expected[0].rdata, expected[0].error, resp.rdata, resp.error);
            end else begin
                $display("Correct Response. Rdata: %0h Error=%b", expected[0].rdata,
                         expected[0].error);
                expected.pop_front();
            end
        end
    end

    logic [31:0] expected_scratch;
    logic [1:0] test_sel;
    response_t expected_resp;

    initial begin
        expected_scratch = 0;

        @(negedge rst_a);
        /*verilog_format: off*/
        repeat (test_no) begin
            test_sel = 2'($urandom_range(0, 3));
            case (test_sel)
                0: begin    //Read ID
                    expected_resp.rdata = 32'hCDC0_0000;
                    expected_resp.error = 1'b0;
                    expected.push_back(expected_resp);
                    read(32'h0000_0000);
                end

                1: begin    //Read scratch
                    expected_resp.rdata = expected_scratch;
                    expected_resp.error = 1'b0;
                    expected.push_back(expected_resp);
                    read(32'h0000_0008);
                end

                2: begin    //Write scratch
                    logic [31:0] data;
                    data = $urandom();

                    expected_resp.rdata = 32'b0;
                    expected_resp.error = 1'b0;
                    expected.push_back(expected_resp);
                    expected_scratch = data;

                    write(32'h0000_0008, data);
                end

                3: begin //Invalid read
                    expected_resp.rdata = 32'b0;
                    expected_resp.error = 1'b1;
                    expected.push_back(expected_resp);
                    read(32'h0000_1000);
                end

                default: begin
                    $fatal("This shouldnt be possible. Generated case: %d", test_sel);
                end
            endcase
        end
        wait(expected.size() == 0);
        $display("Generated %d Requests", test_no);
        $display("Expected responses remaining: %0d", expected.size());
        $display("ALL TESTS PASSED");
        $finish;
    end
endmodule

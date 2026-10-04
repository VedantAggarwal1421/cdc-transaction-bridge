module tb_async_fifo;

    localparam int WIDTH = 32;
    localparam int DEPTH = 8;

    logic wr_clk, rd_clk;
    logic wr_rst, rd_rst;

    logic [WIDTH-1:0] wr_data;
    logic             wr_valid;
    logic             wr_ready;

    logic [WIDTH-1:0] rd_data;
    logic             rd_valid;
    logic             rd_ready;

    async_fifo #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) DUT (
        .wr_clk(wr_clk),
        .wr_rst(wr_rst),

        .wr_data (wr_data),
        .wr_valid(wr_valid),
        .wr_ready(wr_ready),

        .rd_clk(rd_clk),
        .rd_rst(rd_rst),

        .rd_data (rd_data),
        .rd_valid(rd_valid),
        .rd_ready(rd_ready)
    );

    logic [WIDTH-1:0] expected[$];
    logic done;

    initial begin
        wr_clk = 0;
        forever #5 wr_clk = ~wr_clk;
    end

    initial begin
        rd_clk = 0;
        forever #7 rd_clk = ~rd_clk;
    end

    task automatic write(input logic [WIDTH-1:0] data);

        @(negedge wr_clk);

        wr_data  = data;
        wr_valid = 1;

        while (1) begin
            @(posedge wr_clk);

            if (wr_ready) begin
                $display("WROTE: %d, TIME: %0t", wr_data, $time);
                break;
            end
        end

        @(negedge wr_clk);
        wr_valid = 0;

    endtask

    initial begin
        wr_rst   = 1;
        rd_rst   = 1;

        wr_valid = 0;
        wr_data  = 0;
        rd_ready = 0;

        #30;

        wr_rst = 0;
        rd_rst = 0;

    end

    initial begin
        done = 0;
        @(negedge wr_rst);

        for (int i = 0; i < 32; i++) write(i);

        done = 1;
    end

    initial begin
        wait (done);
        wait (expected.size() == 0);

        $display("TEST PASSED");
        $finish;
    end

    always @(negedge rd_clk) begin
        if (!rd_rst) rd_ready = 1'($urandom_range(0, 1));
    end

    always @(posedge wr_clk) begin
        if (!wr_rst && wr_valid && wr_ready) expected.push_back(wr_data);
    end

    always @(posedge rd_clk) begin
        if (!rd_rst && rd_valid && rd_ready) begin
            if (expected.size() == 0) begin
                $error("FIFO produced data when scoreboard is empty");
            end else if (rd_data !== expected[0]) begin
                $error("DATA MISMATCH: expected=%h got=%h", expected[0], rd_data);
            end else begin
                $display("READ: %d, TIME: %0t", expected.pop_front(), $time);
            end
        end
    end

endmodule

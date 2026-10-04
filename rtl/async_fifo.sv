module async_fifo #(
    parameter int WIDTH = 32,
    parameter int DEPTH = 8
) (
    input logic wr_clk,
    input logic wr_rst,

    input  logic [WIDTH-1:0] wr_data,
    input  logic             wr_valid,
    output logic             wr_ready,

    input logic rd_clk,
    input logic rd_rst,

    output logic [WIDTH-1:0] rd_data,
    output logic             rd_valid,
    input  logic             rd_ready
);

    logic [WIDTH-1:0] fifo[0:DEPTH-1];

    localparam ADDR_WIDTH = $clog2(DEPTH);
    localparam PTR_WIDTH = ADDR_WIDTH + 1;

    logic [PTR_WIDTH-1:0] write_ptr, read_ptr;
    logic [PTR_WIDTH-1:0] write_ptr_gray, read_ptr_gray;
    logic [PTR_WIDTH-1:0] w2r_ptr_gray, r2w_ptr_gray;

    logic fifo_full;
    logic fifo_empty;

    //Read Pointer section

    //Write pointer to gray code
    assign write_ptr_gray = write_ptr ^ (write_ptr >> 1);

    //Synchronise write pointer to read clock domain
    sync_2ff #(
        .WIDTH(PTR_WIDTH)
    ) write2read (
        .clk (rd_clk),
        .rst (rd_rst),
        .din (write_ptr_gray),
        .dout(w2r_ptr_gray)
    );

    assign fifo_empty = (w2r_ptr_gray == read_ptr_gray);

    assign rd_valid = !fifo_empty;  //As long as fifo is not empty read is valid
    assign rd_data = fifo[read_ptr[ADDR_WIDTH-1:0]];  //Combinational read

    always @(posedge rd_clk or posedge rd_rst) begin
        if (rd_rst) begin
            read_ptr <= '0;
        end else if (rd_valid && rd_ready) begin
            read_ptr <= read_ptr + 1'b1;  //Increment read pointer if not empty and requesting data
        end
    end


    //Write Pointer Section

    //Convert read pointer to gray code
    assign read_ptr_gray = read_ptr ^ (read_ptr >> 1);

    //Synchronize read pointer to write clock domain
    sync_2ff #(
        .WIDTH(PTR_WIDTH)
    ) read2write (
        .clk (wr_clk),
        .rst (wr_rst),
        .din (read_ptr_gray),
        .dout(r2w_ptr_gray)
    );

    logic [PTR_WIDTH-1:0] write_ptr_next;
    logic [PTR_WIDTH-1:0] write_ptr_next_gray;

    assign write_ptr_next = write_ptr + 1'b1;
    assign write_ptr_next_gray = write_ptr_next ^ (write_ptr_next >> 1'b1);

    assign fifo_full = write_ptr_next_gray == {~r2w_ptr_gray[PTR_WIDTH-1:PTR_WIDTH-2], r2w_ptr_gray[PTR_WIDTH-3:0]};
    assign wr_ready = !fifo_full;  //As long as fifo not full we can write to it

    always @(posedge wr_clk or posedge wr_rst) begin
        if (wr_rst) begin
            write_ptr <= '0;
        end else if (wr_valid && wr_ready) begin
            fifo[write_ptr[ADDR_WIDTH-1:0]] <= wr_data;
            write_ptr <= write_ptr_next;
        end
    end

endmodule

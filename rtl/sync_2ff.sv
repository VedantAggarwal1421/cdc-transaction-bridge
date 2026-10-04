module sync_2ff #(
    parameter WIDTH = 3
) (
    input  logic             clk,
    input  logic             rst,
    input  logic [WIDTH-1:0] din,
    output logic [WIDTH-1:0] dout
);

    logic [WIDTH-1:0] sync_ff;

    always @(posedge clk or posedge rst) begin
        if (rst) {dout, sync_ff} <= '0;
        else {dout, sync_ff} <= {sync_ff, din};
    end
endmodule

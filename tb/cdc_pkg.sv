package cdc;

    typedef struct packed {
        logic        write;
        logic [31:0] addr;
        logic [31:0] wdata;
        logic [3:0]  wstrb;
    } request_t;

    typedef struct packed {
        logic [31:0] rdata;
        logic        error;
    } response_t;

endpackage

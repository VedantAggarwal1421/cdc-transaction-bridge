package cdc;

    typedef struct packed {
        logic        write;
        logic [31:0] addr;
        logic [31:0] wdata;
    } request_t;

    typedef struct packed {
        logic [31:0] rdata;
        logic        error;
    } response_t;

endpackage

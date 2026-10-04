# CDC Transaction Bridge

A CDC safe transaction bridge for transferring memory mapped requests and responses between two unrelated clock domains.
The bridge uses asynchronous FIFOs with Gray-coded pointers and synchronized pointer crossings to safely transfer transactions across clock domains. It provides valid/ready request and response interface and includes a test memory mapped peripheral for verification purposes.

## Features

* CDC safe request and response transfer between unrelated clock domains
* Parameterized asynchronous FIFO with Gray-coded pointers
* Two stage synchronizers for clock domain crossings
* Valid/ready transaction interfaces
* Randomized, self-checking bridge verification
* Standalone asynchronous FIFO testbench

## Dependencies

* [Verilator](https://verilator.org/)
* GNU Make

## Running

Clone the repository and run:

```bash
git clone https://github.com/VedantAggarwal1421/cdc-transaction-bridge
cd cdc-transaction-bridge
make
```

The default testbench performs randomized transactions across the CDC bridge and automatically checks the returned responses.
A separate asynchronous FIFO testbench is provided in `tb/` for independently verifying FIFO behavior.

## Verification
The bridge testbench exercises reads, writes, invalid accesses, randomized write data, FIFO backpressure, and transaction ordering across unrelated clock domains.

# Synchronous FIFO — Verilog/SystemVerilog

A parameter-free, **8-bit-wide, 4-entry synchronous FIFO** implemented in SystemVerilog, featuring read/write pointers, occupancy tracking, full/empty flags, and a registered read output.

## Overview

A FIFO (First-In, First-Out) is a storage structure in which data is read in the same order it was written. This project implements a synchronous FIFO in which both read and write operations use the same clock.

The design demonstrates fundamental RTL concepts, including sequential logic, pointer management, counter-based occupancy tracking, status flags, and self-checking testbench development.

## Features

- **Data width:** 8 bits
- **FIFO depth:** 4 entries
- **Clocking:** Single shared clock
- **Reset:** Active-high synchronous reset
- **Read output:** Registered
- **Status flags:** `full` and `empty`
- **Pointer management:** Read and write pointers with wraparound
- **Occupancy tracking:** 3-bit counter representing 0–4 stored entries
- **Simultaneous operations:** Supports a read and write in the same clock cycle when both are accepted

## Architecture

The FIFO consists of four primary components:

| Component | Purpose |
|---|---|
| Storage array | Stores four 8-bit data words |
| Write pointer | Selects the memory entry for the next accepted write |
| Read pointer | Selects the memory entry for the next accepted read |
| Occupancy counter | Tracks the number of stored entries and supports full/empty detection |

The read and write pointers wrap around after reaching the last memory entry, allowing the storage locations to be reused.

### Block Diagram

```text
             +-------------------------+
data_in ---->|                         |
wr_en ------>|      Synchronous FIFO   |----> data_out
rd_en ------>|                         |
clk -------->|  Memory + Read Pointer  |
rst -------->|  Write Pointer + Count  |
             |                         |----> full
             |                         |----> empty
             +-------------------------+
```

## FIFO Operation

### Write operation

A write is accepted only when `wr_en` is asserted and the FIFO is not full:

```systemverilog
wr_en && !full
```

On an accepted write, the input data is stored at the current write-pointer location, and the write pointer advances with wraparound.

### Read operation

A read is accepted only when `rd_en` is asserted and the FIFO is not empty:

```systemverilog
rd_en && !empty
```

On an accepted read, the data at the current read-pointer location is transferred to the registered output, and the read pointer advances with wraparound.

### Full and empty conditions

- **Empty:** The occupancy count is zero.
- **Full:** The occupancy count is four.

The occupancy counter is updated according to the accepted read and write operations.

| Accepted write | Accepted read | Occupancy update |
|---|---|---|
| No | No | Unchanged |
| Yes | No | Increment |
| No | Yes | Decrement |
| Yes | Yes | Unchanged |

The FIFO uses conservative, pre-edge status flags: an operation is accepted based on the `full` and `empty` values before the active clock edge.

Consequently:
- When full, a simultaneous read and write request accepts the read but rejects the write.
- When empty, a simultaneous read and write request accepts the write but rejects the read.

## Verification

A directed, self-checking SystemVerilog testbench was developed to verify the FIFO's basic functionality.

The testbench covers:

- Reset behavior
- FIFO data ordering
- Filling the FIFO to capacity
- Full and empty status conditions
- Rejection of writes when full
- Simultaneous accepted read/write operations
- Basic read/write behavior and pointer wraparound

**Result:** All implemented directed test cases passed.

The current verification is directed rather than exhaustive. Randomized testing, assertions, and functional coverage are potential future enhancements.

## Tools

- SystemVerilog
- EDA Playground
- Icarus Verilog
- EPWave

## Key Learning Outcomes

- Modeling sequential hardware using `always_ff` and nonblocking assignments
- Understanding synchronous reset behavior
- Implementing read/write pointers and circular buffer wraparound
- Managing FIFO occupancy with a counter
- Handling simultaneous read/write requests
- Developing self-checking testbenches
- Debugging RTL through simulation waveforms

## Future Improvements

- Add parameterized data width and FIFO depth
- Develop randomized tests and stronger reference-model-based checking
- Add SystemVerilog assertions and functional coverage
- Explore alternative full/empty detection methods
- Implement an asynchronous FIFO with independent read and write clocks

---

*This project is part of my RTL design portfolio, focused on building and verifying fundamental digital hardware blocks using Verilog/SystemVerilog.*

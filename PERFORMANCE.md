# Microarchitectural Performance Analysis — RV32I Single-Cycle Core

## Core Specifications

| Property | Detail |
|---|---|
| ISA | RISC-V RV32I base integer instruction set |
| Microarchitecture | Single-cycle datapath |
| Instructions implemented | ADD, SUB, AND, OR, XOR, LW, SW, BEQ, JAL, LUI |
| Instruction formats | R, I, S, B, U, J |
| HDL | Verilog |
| Simulation tool | Icarus Verilog v12 |
| Waveform viewer | GTKWave v3.3.100 |


## Module Hierarchy and Datapath

```text
riscv_core (top)
+-- datapath
|   +-- imem    : Instruction memory (PC-indexed fetch)
|   +-- regfile : 32 x 32-bit register file (2 read ports, 1 write port)
|   +-- imm_ext : Immediate sign extender (handles all 6 formats)
|   +-- alu     : Arithmetic and logic unit
+-- control_unit
|   +-- main_dec : Main decoder (generates datapath control signals)
|   +-- alu_dec  : ALU decoder (selects ALU operation from funct3/funct7)
+-- dmem : Data memory (word-addressable read/write)
```

All stages (fetch → decode → execute → memory → writeback) complete
combinationally within a single clock cycle.


## CPI Analysis

**Theoretical CPI = 1.0** — by single-cycle design, every instruction
completes in exactly one clock cycle.

This is the best possible CPI. However, CPI alone does not determine
performance:

```text
Throughput = IPC / Clock_Period = 1.0 / T_critical_path
```

A single-cycle processor forces the clock period to accommodate the
worst-case combinational delay in the entire datapath. This becomes the
main performance limitation of the design.

### Fibonacci Benchmark Results

The included testbench computes the first 8 Fibonacci numbers using
ADD instructions:

```text
1, 1, 2, 3, 5, 8, 13, 21
```

- **Workload type:** ALU-bound (ADD-only, no memory access)
- **CPI observed:** 1.0
- **Register utilisation:** x1–x8 written sequentially
- **Memory traffic:** Zero (no LW/SW)

While checking the GTKWave traces, I noticed the register writeback values
were appearing exactly one cycle after the ALU output stabilised, which
initially confused me because I expected both to change “at once.” After
stepping through the waveform more carefully, it became clear that the
write happens only on the active clock edge even though the datapath itself
is combinational between edges.

I also spent an embarrassing amount of time thinking my BEQ logic was broken
because the PC briefly showed an unknown (`x`) value during reset release —
it turned out to be an uninitialised testbench signal rather than the core.

This Fibonacci workload is effectively the best-case scenario for the
processor since no data memory accesses occur. Programs with frequent LW/SW
instructions exercise the full datapath every cycle and therefore expose
the real timing bottleneck.


## Critical Path Analysis

In a single-cycle design, the clock period equals the longest combinational
path from any input to any output.

The logical stages are:

- Stage 1: IF  — PC → imem → instruction bits
- Stage 2: ID  — instruction bits → control_unit + regfile read + imm_ext
- Stage 3: EX  — register data + immediate → alu result
- Stage 4: MEM — alu address → dmem read/write
- Stage 5: WB  — dmem output or alu result → regfile write

### Worst-case path: LW (load word)

```text
PC → imem → main_dec → regfile(read) → imm_ext
→ alu(add) → dmem(read) → regfile(write)
```

Every stage executes combinationally for LW. This path sets the clock
frequency for *all* instructions, including simple ADD operations that
never access data memory.

### Best-case path: R-type instructions

```text
PC → imem → main_dec → regfile(read)
→ alu → regfile(write)
```

The dmem stage is bypassed, but because the clock is determined by the
worst-case LW path, even simple ALU operations must wait for the longer
clock period anyway (which feels slightly wasteful once you actually see
the timing paths laid out).

### Critical path delay breakdown

| Stage | Dominant component | Relative delay |
|---|---|---|
| IF | imem read | Medium |
| ID | regfile read | Low |
| EX | alu propagation | Low–Medium |
| MEM | dmem read (LW) | **High — sets clock period** |
| WB | regfile write | Low |


## Performance Tradeoffs vs Pipelined Design

| Property | This core (single-cycle) | 5-stage pipeline |
|---|---|---|
| CPI (ideal) | 1.0 | ~1.0 |
| Clock frequency | Low — limited by LW path | Higher — each stage ~1/5 delay |
| Instruction throughput | Limited by critical path | Higher at same technology node |
| Hazard logic needed | None | Data hazards + control hazards |
| Load-use stall | None (not needed) | 1 cycle stall |
| Branch penalty | None | 1–2 cycle flush |
| Hardware complexity | Low | Moderate |
| Area efficiency | Simple, easy to verify | More logic + pipeline registers |

### Pipelining the critical path

In a 5-stage pipeline version of this same design:

- Clock period ≈ max(T_IF, T_ID, T_EX, T_MEM, T_WB)
- T_MEM still dominates but is isolated from the other stages
- Clock frequency would improve significantly because the full datapath no longer has to settle in one cycle
- New problem introduced: forwarding and hazard detection for RAW dependencies

Example:

```assembly
ADD x1, x2, x3
ADD x4, x1, x5
```

The second instruction immediately depends on the first result, so a
pipeline would require either forwarding logic or a stall cycle.


## Memory Subsystem Analysis

| Memory | Type | Addressing | Notes |
|---|---|---|---|
| imem | Read-only, combinational | Word-addressed by PC | Instruction fetch |
| dmem | Read/Write, combinational | Word-addressed by ALU output | Used by LW, SW |

Both memories are modelled as zero-latency combinational reads in
simulation. In real hardware, SRAM access latency would likely dominate
timing and introduce stalls or wait states.

This simplification is common in academic single-cycle processors, but it
became obvious during analysis that the memory stage is the real bottleneck
even in this simplified version.


## Instruction Mix Impact on Effective Performance

Different workloads stress different parts of the processor.

### ALU-bound workload
Example: Fibonacci benchmark

- Mostly ADD instructions
- No memory traffic
- CPI = 1.0
- Highest effective throughput on this core

### Memory-bound workload
Example: array traversal with LW/SW

- Frequent memory accesses
- Full critical path exercised every cycle
- CPI remains 1.0 theoretically, but clock period is constrained by dmem latency

### Branch-heavy workload
Example: loops using BEQ

- Branch decision occurs in EX stage
- No explicit branch penalty in this single-cycle implementation
- In a pipelined processor this would introduce control hazards and flushes


## Reflections on Modern CPUs

Working through this design made some modern CPU design choices feel much
less abstract to me.

For example, the reason processors like AMD Zen-class CPUs or Intel Core
processors use very deep pipelines suddenly made practical sense: the exact
same critical-path problem exists here, just at a much smaller scale. If
this tiny RV32I core already struggles to keep the clock period short
because of one long LW path, then reaching multi-GHz frequencies on modern
CPUs basically requires slicing logic into many smaller stages.

It also made me appreciate why out-of-order execution exists. In this core,
a long memory stall would freeze the entire processor. Modern CPUs instead
try to execute independent instructions while waiting on memory, which is a
much smarter use of the hardware.


## Future Work

The next step I want to implement is a full 5-stage pipeline version of
this processor with forwarding and hazard detection. I think actually
measuring the frequency improvement and observing stalls in GTKWave will be
more interesting than just predicting them theoretically.

I also want to add a simple cache or memory-latency model because the
current zero-latency dmem makes the processor look much faster and cleaner
than a realistic implementation would be.

Longer term, porting the design into a simulator like gem5 and comparing
RTL behaviour against a higher-level CPU model would be useful for studying
IPC and memory effects in a more quantitative way.

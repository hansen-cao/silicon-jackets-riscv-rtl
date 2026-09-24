# RISC-V RTL Implementation — Silicon Jackets

My SystemVerilog implementation of instruction decoding, ALU logic, and a six-state controller for an RV32I-subset processor, completed as part of Georgia Tech Silicon Jackets' Fall 2026 digital design onboarding project.

I implemented the logic in **`decode.sv`, `alu.sv`, and `control.sv`**, then instantiated and connected my control and ALU modules within the supplied **`cpu_top.sv`** scaffold. I also added four directed assembly tests and used Cadence Xcelium and SimVision to test and debug the integrated processor.

**Recorded regression result: 16 passed, 0 failed.**

## My RTL contributions

| File | What I implemented |
| --- | --- |
| [`decode.sv`](src/verilog/cpu/decode.sv) | Instruction decoding and sign extension of I-, S-, and B-type immediates. |
| [`alu.sv`](src/verilog/cpu/alu.sv) | Addition, subtraction, logical shifts, load/store address generation, and branch comparison and target calculation. |
| [`control.sv`](src/verilog/cpu/control.sv) | A six-state finite-state machine coordinating instruction execution, register writeback, memory transactions, branches, and halt behavior. The decoder is instantiated inside this module. |
| [`cpu_top.sv`](src/verilog/cpu/cpu_top.sv) | Instantiation and signal connections for my control and ALU modules within the existing top-level scaffold. My contribution is the added integration code, not authorship of the entire file. |

### Instruction decoding

In `decode.sv`, I implemented operation selection from instruction fields and construction of sign-extended immediates:

- **I-type:** immediate arithmetic and load offsets
- **S-type:** store offsets
- **B-type:** branch offsets, including the implicit low-order zero bit

The implemented instruction subset covers ADD, ADDI, SUB, SLL, SRL, LW, SW, BEQ, and EBREAK behavior. This is an educational subset implementation, not a complete RV32I-compliant processor; full instruction-encoding validation and exception handling are outside the demonstrated scope.

### ALU and address generation

In `alu.sv`, I implemented:

- ADD/ADDI and SUB results
- Logical left and right shifts using the lower five bits of the shift operand
- Base-plus-offset addresses for loads and stores
- Conversion of byte addresses to the supplied memory interface's word addresses
- Equality comparison and target calculation for branches
- Default combinational output assignments

### Execution control

In `control.sv`, I implemented the **FETCH, DECODE, EXECUTE, WRITEBACK, MEM, and BRANCH** states. The controller captures instruction and PC values, controls register writes, issues memory requests, waits for memory-ready responses, and handles branch and EBREAK behavior.

## Verification and debugging

I used **Cadence Xcelium** for simulation and **SimVision** for waveform-based debugging. The uploaded [`regress.log`](regress.log) records all 16 tests passing, including baseline instruction tests, two multi-instruction programs, and the four directed tests I added below.

| Additional test | Behavior exercised |
| --- | --- |
| [`my_b2b_branch`](tests/my_b2b_branch/program.asm) | A not-taken branch immediately followed by a taken branch |
| [`my_imm_neg`](tests/my_imm_neg/program.asm) | Negative immediates, including `-2048` and `-1` |
| [`my_shift0`](tests/my_shift0/program.asm) | Zero-amount and nonzero logical shifts |
| [`my_x0`](tests/my_x0/program.asm) | Attempting to write `x0`, then using it as a source operand |

```text
16 passed, 0 failed (of 16)
```

This result describes functional simulation of the included test suite. It does not establish full ISA compliance, exhaustive verification, synthesis timing, or operation on fabricated silicon.

## Supplied framework and attribution

Silicon Jackets provided the onboarding scaffold and supporting code, including:

- Instruction fetch and register-file modules
- The CPU package and top-level scaffolding
- Chip-level integration, memory controller, and SRAM wrapper
- A third-party SRAM simulation model
- The processor testbench, simulation file lists, and baseline tests

These files support integration and testing of my RTL. I do not claim authorship of them. Original headers and notices should remain with the supplied files. The four RTL files listed above identify where I made my implementation contributions; `cpu_top.sv` contains both supplied scaffolding and my additions.

## Repository navigation

Start with the **My RTL contributions** table to review my implementation, then the four additional assembly tests and the regression log. Supporting files retain the original project layout so their relationships remain clear.

## Simulation environment

The recorded result was produced with Cadence Xcelium; waveform inspection used SimVision. The supplied compilation file list is [`sim/behav/Include/cpu.include`](sim/behav/Include/cpu.include).

The uploaded project snapshot does not include a standalone regression runner. Reproducing the full regression requires the corresponding onboarding simulation/test-generation workflow and tool environment. The file list alone is not a complete run procedure.

## Author

**Wenhan (Hansen) Cao**  
Electrical Engineering, Georgia Institute of Technology

[GitHub](https://github.com/Hansen-Cao) · [Portfolio](https://hansen-cao-engineering.wcao78.chatgpt.site)

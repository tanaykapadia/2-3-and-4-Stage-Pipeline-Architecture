
# 2, 3 and 4-Stage Pipeline Architecture

## Objectives

- Designing and implementing a simple processor
- Implementing different pipelining configurations (2-stage, 3-stage and 4-stage)
- Analysis of the performance for each pipelining configuration

## Structure of Code

The repository contains different folders that implement the different pipelines. They contain a top-level module file named as `ProcessorCore.v` which includes the files and establishes the connections between different modules that represent different stages of the processor.

There are 5 units defined for the 5 stages of the processor, namely:

1. Instruction Fetch (F)
2. Operand Fetch / Decode (D)
3. Execute (E)
4. Memory Access (M)
5. Register Writeback (W)

The `InstructionMemory.v` file contains the instructions that are to be run. A maximum of 256 instructions are supported. Note that we are concerned with only the architecture of a processor, so it is assumed that the instructions are loaded in the memory implemented in this module.

A separate test-bench file by the name of `ProcessorCore_TB.v` is included which handles the functioning of the clock edges and also validates the functioning of the processor by returning the required data (register values, control signals, etc.) on the terminal.

To run the code on the terminal, you can install and use the iVerilog compiler, and apply the following commands on the terminal in the relevant folder:
> iverilog -o out.vvp ProcessorCore_TB.v ProcessorCore.v\
> vvp out.vvp

## Instruction Set Architecture

Our processor is based on the SimpleRISC ISA, as described in [Basic Computer Architecture by Smruti R. Sarangi](https://www.cse.iitd.ac.in/%7Esrsarangi/archbook/archbook.pdf) and discussed extensively in CSC-201 lectures.

The ISA encodes 21 instructions in a 32-bit instruction format. It includes 16 registers (r0 to r15), with r15 being the return address register. The program also uses 32 bit memory addressing of 256 words for load and store operations. The following tables (from the book) succinctly summarizes the instruction formats.

| Inst. | Code  | Format                 | Inst. | Code  | Format                 |
|-------|-------|------------------------|-------|-------|------------------------|
| add   | 00000 | add rd, rs1, (rs2/imm) | lsl   | 01010 | lsl rd, rs1, (rs2/imm) |
| sub   | 00001 | sub rd, rs1, (rs2/imm) | lsr   | 01011 | lsr rd, rs1, (rs2/imm) |
| mul   | 00010 | mul rd, rs1, (rs2/imm) | asr   | 01100 | asr rd, rs1, (rs2/imm) |
| div   | 00011 | div rd, rs1, (rs2/imm) | nop   | 01101 | nop                    |
| mod   | 00100 | mod rd, rs1, (rs2/imm) | ld    | 01110 | ld rd, imm[rs1]        |
| cmp   | 00101 | cmp rs1, (rs2/imm)     | st    | 01111 | st rd, imm[rs1]        |
| and   | 00110 | and rd, rs1, (rs2/imm) | beq   | 10000 | beq offset             |
| or    | 00111 | or rd, rs1, (rs2/imm)  | bgt   | 10001 | bgt offset             |
| not   | 01000 | not rd, (rs2/imm)      | b     | 10010 | b offset               |
| mov   | 01001 | mov rd, (rs2/imm)      | call  | 10011 | call offset            |
|       |       |                        | ret   | 10100 | ret                    |

| Format    | Definition                                                                       |
|-----------|----------------------------------------------------------------------------------|
| branch    | op (28-32) &#124; offset (1-27)                                                  |
| register  | op (28-32) &#124; I (27) &#124; rd (23-26) &#124; rs1 (19-22) &#124; rs2 (15-18) |
| immediate | op (28-32) &#124; I (27) &#124; rd (23-26) &#124; rs1 (19-22) &#124; imm (1-18)  |

Key: *op* &rarr; opcode, *offset* &rarr; branch offset, *I* &rarr; immediate bit, *rd* &rarr; destination register, *rs1* &rarr; source register 1, *rs2* &rarr; source register 2, *imm* &rarr; immediate operand

## Pipelining

The ISA is integrated with a pipelining mechanism implemented using 'latch' modules. These modules store incoming data in registers and release it at appropriate clock cycles. By maintaining multiple copies of relevant data and control signals, the latch modules effectively divide the processor into separate stages, allowing an *n*-stage pipeline to process *n* sets of data concurrently.

### 2-Stage Pipeline

In the 2-stage pipeline, we are implementing a latch between the decode and execute units, meaning at a time, there are a maximum of two instructions in the pipeline.

### 3-Stage Pipeline

In the 3-stage pipeline, in addition to the latch between decode and execute, we are now applying another latch in between fetch and decode.

### 4-Stage Pipeline

In the 4-stage pipeline, an additional latch is added between the execute and memory units. This setup creates a total of four stages: the memory access and register writeback units together can hold one instruction at a time, while each of the other units can hold its own separate instruction.

### Hazards

In each pipeline configuration, a dedicated hazard unit is needed to handle dependencies. To manage Read-After-Write (RAW) data dependencies, a stall signal is used to pause the dependent instruction for the necessary number of cycles whenever a dependency is detected.

For control dependencies, we are making use of a different stall wire that will make sure that instructions are loaded only after the branch target is calculated by a branch instruction.

Although this will eventually hamper the CPI (Cycles Per Instruction), it is of utmost importance for the correctness of code.

## CPI Analysis

The `InstructionMemory.v` file in each pipeline implementation contains an assembly program that calculates the factorial of 5 using a loop, which takes 18 instructions.

The CPI will be calculated by checking the number of cycles that the program runs for in the terminal, and will be compared to the ideal CPI.

The ideal CPI shall be calculated using the formula: $ n + k - 1 \over k $, where n is the number of instructions in the program and k is the number of stages in the pipeline.

### 2-Stage

Using the formula, we get an ideal CPI of 1.06. However, when the factorial program is ran on the processor, the CPI obtained is 1.50.

### 3-Stage

Using the formula, we get a CPI of 1.11, while for the following program, we get 1.72.

### 4-Stage

Using the formula, we get a CPI of 1.17, while for the following program, we get 2.06.

## Contributors

Arnav Gupta (23114010), Krish Singla (23114050), Megh Bhavesh Shah (23114065), Tanay Kapadia (23323044), Vaghasiya Jay (23114104)

Made as a course project for CSC-201 (Computer Organization & Architecture), IITR

# Overview #
Just a simple brainteaser from a work social event. This project is a solver written in x86_64 assembly, [mostly] for fun.

## Problem Statement ##
The security door passcode is a seven digit number whose digits total 35. The fourth digit is three more than the first digit, the fifth digit is four more than the second digit, the sixth digit is one less than the fourth digit, the last digit is one less than twice the second digit, and the sum of the first and third digits is one more than the fourth digits. However, the passcode has no repeated digits. Digits must be > 0 and < 10. What is the passcode?

## General Approach ##
This is obviously trivial for a human with some basic knowledge of algebra. It's not an interesting problem for a human to solve, but it is a mildly interesting problem to try to get a computer to solve.<br>

Rather than deriving the solution from the constraints, the approach is more brute force; trying combinations one by one and rejecting ones that don't fit.<br>

Using 9 variables, we permute through all possible combinations (9! possibilities) and check the first 7 variables against the passcode constraints. With 7 unique digits in the passcode, there are 9! - 2! combinations.

## Implementation ##
- Using Heap's algorithm for producing all permutations.
- Specifically, we are using 9 bytes of a 128-bit x86_64 SIMD register.
- Only 7 bytes (indices 0-6) are checked against constraints.
- I cheated a little bit by starting off with a sequence where every digit was already unique and between 1-9.
  - The code should work with any ordering of the digits in the starting sequence.
- Requires 36,381 permutations when starting from 123456789 to find the answer.

## Building ##
Build Requirements
- An **x86_64** CPU that supports at least SSE3 (anything post-2005 will likely work). I've tested on both Intel and AMD CPUs.
- **GNU Make**&mdash;Just run 'make' to assemble, link, and run the binary.
- **NASM** (Netwide Assembler)&mdash;I don't think I use anything nasm-specific, so any other x86_64 assembler on a Unix-like system would probably work. Just make sure it supports Intel syntax.
- **GNU sed**&mdash;The Makefile will use sed to fill in the syscall numbers for exiting and printing for either Linux or macOS.
- A **Unix-like** system&mdash;I've tested it on Linux and macOS 10.15.

## Notes ##
### Assembly Syntax ###
I am using Intel syntax in this project. I have used both AT&T and Intel (and even ARM) in the past and they're all fine; no preference either way. If you're not familiar with Intel syntax, the ordering of operands may be confusing.
- Most instructions are of the form 'op dest,src[,src,etc...]'
- Often the destination is used as one of the source operands
  - For example: 'add rax,rcx' means 'rax = rax + rcx'

I am completely ignoring the Unix ABI calling conventions as to which function arguments are passed in which registers, which registers are callee/caller saved, etc.<br>

I am using a flat memory model, since there is no segmentation in 64-bit mode.

### SSE/AVX ###
It is very hard to find examples and clear documentation of SSE/AVX instructions such as PINSRB and PSHUFB. The Intel manual shows how to use the instructions in general terms, but not clear examples of syntax or the ordering of vector elements. Various internet forum posts, almost without exception, discuss in terms of compiler instrinsics instead of the mnemonics using AT&T or Intel syntax.
- Constructing a shuffle byte mask for PSHUFB was particularly unclear. The clue I needed (that may help others) is that most SIMD-type instructions in x86_64 indicate the source element in destination element order. Meaning that, for example, element 0 of your shuffle mask containing 4 indicates that the resulting vector should get element 0 from element 4.
- One frustrating limitation of most SIMD instructions (though this is somewhat remedied with the introduction of AVX512) is that the element selection has to be an immediate value. There is no dynamic selection of elements. I worked around this by using some jump tables for byte insertion and extraction.

### Instruction Timing ###
- I made extensive use of Agner Fog's instruction tables to weigh tradeoffs when deciding which SIMD instructions to use.
- https://www.agner.org/optimize/instruction_tables.pdf
- I'm developing this on a machine with a 4-core/8-thread Intel Core i7-8665U processor (Whiskey Lake). I based my rough timing calculations on the Coffee Lake tables, even though those are 9th gen.

### Calculating Constraints ###
One of the major goals of this project was to try to check constraints simultaneously with SIMD instructions.
- There is some value in calculating constraints one by one, as it potentially allows us to weed out incorrect passcodes earlier. This probably would give a lower total runtime, so I included that code but commented it out.
- Reordering the checks may give a faster overall runtime for a given set of starting digits.

### Drawbacks of General Approach ###
- Because the last 2 digits are not a part of the passcode, we are generating more permutations than we need. A given incorrect 7 digit passcode may actually be checked against the constraints multiple times because it is part of multiple distinct permutations of the 9 total digits.
- This is a brute force approach, which is straightforward to code and reason about. Framing this problem in linear algebra terms or solving symbolically would be much more elegant. (Maybe a future project...)

## Performance ##
I was able to run this on my Intel Whiskey Lake machine, and an AMD EPYC Milan machine. This is only single-threaded code, so core count doesn't help here and single-threaded performance is what we want. The performance difference between both machines wasn't discernable beyond noise. I didn't enable any optimization in the assembler or linker.

According to the 'perf' utility in Linux (which mostly just accesses CPU performance counters), I averaged the following numbers over multiple runs. My CPU frequency kept going up and down wildly (between 1.2GHZ - 4.5GHZ). Would get much more reliable performance numbers if I pinned the frequency.
- Instruction count: 3,497,779 as of this writing
- Instructions per cycle: ranging from 0.9-2.8
- CPU cycles: ranging from 1,306,980-3,645,393
- L1 d-cache loads: fairly consistent around 705,854
- L1 d-cache load misses: ranging from 10-20
- Branches: 1,462,579 as of this writing
- Branch misses: about 1%
- Page faults: 2
- Stalled CPU cycles: around 100k frontend, 1k backend
  - Note: this was only enabled on my AMD machine. I don't have Intel numbers
- Time elapsed: ranging from 1031-1760 microseconds

## Final Thoughts ##
- The point of this project was to delve back into assembly and have some fun. It seemed a particularly good fit to try to learn a bit about SIMD instructions, because of the ease of representing a set of numbers in a single register and checking multiple constraints simultaneously.
- It turns out that using SIMD registers and instructions has a lot more overhead than I thought. Various SIMD instructions I looked at either lack dynamic operands (pextrb/pinsrb), included unwanted effects (punpckhbw/punpcklbw), or are significantly slower than breaking the operation down and doing it with simpler instructions (phaddw). I think a much larger set of numbers and constraints would better show off the power of SIMD.
- I was a little disappointed that I didn't even get to touch any AVX/AVX2 instructions. I think the most modern SIMD instruction set I use is SSE3.
- I'm reminded yet again why we have optimizing compilers, and how much better they are at this than most humans.

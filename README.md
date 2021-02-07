# Overview #

## Problem Statement ##
The security door passcode is a seven digit number whose digits total 35. The fourth digit is three more than the first digit, the fifth digit is four more than the second digit, the sixth digit is one less than the fourth digit, the last digit is one less than twice the second digit, and the sum of the first and third digits is one more than the fourth digits. However, the passcode has no repeated digits. Digits must be > 0 and < 10. What is the passcode?

## General Approach ##
Using 9 variables, we permute through all possible combinations (9! possibilities) and check the first 7 variables against the passcode constraints. With 7 unique digits in the passcode, there are 9! - 2! combinations.

## Implementation ##
- Using Heap's algorithm for producing all permutations
- Specifically, we are using 9 bytes of a 128-bit x86_64 vector register.
- Only 7 bytes (indices 0-6) are checked against constraints

## Notes ##
### SSE/AVX ###
- It is very hard to find examples and clear documentation of SSE/AVX instructions such as PINSRB and PSHUFB. The Intel manual shows how to use the instructions in general terms, but not clear examples of syntax or the ordering of vector elements. Various forums, almost without exception, used compiler instrinsics instead of the mnemonics using ATT or Intel syntax.
- Constructing a shuffle byte mask for PSHUFB was particularly unclear. The clue I needed (that may help others) is that most SIMD-type instructions in x86_64 indicate the source element in destination element order. Meaning that, for example, element 0 of your shuffle mask containing 4 indicates that the resulting vector should get element 0 from element 4.
- One frustrating limitation of most AVX instructions (though this is somewhat remedied with the introduction of AVX512) is that the element selection has to be an immediate value. There is no dynamic selection of elements. I worked around this by using a lot of jump tables to avoid code duplication.

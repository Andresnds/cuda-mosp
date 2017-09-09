# cuda-mosp

This repository is the CUDA C/C++ implementation for paralellizing solutions to the Minimization of Open Stacks Problem.

## Abstract
This paper presents the use of heterogeneous computing, with massive parallel architectures,
for solving the Minimization of Open Stacks Problem (MOSP). We introduce
optimizations in two solutions for the problem, one using brute force and another using
dynamic programming. We used GPU as the massive parallel computing architecture,
which was programmed with CUDA C/C++. Comparing the equivalent sequential implementation
for each solution, we got a performance gain from 2x to 3x on the brute force implementation
and from 3x to 12x on the dynamic programming implementation.

## White paper

If you can read Portuguese, give a look at the white paper:
https://drive.google.com/file/d/0B716ljvxllWYTjgxcVpad3UyU1k/view?usp=sharing

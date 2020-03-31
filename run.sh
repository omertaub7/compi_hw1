#!/bin/bash

flex hw1.lex
gcc -o prog.o -ll lex.yy.c
./prog.o

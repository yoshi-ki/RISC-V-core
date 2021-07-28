#!/bin/bash
xvlog --sv test_cpu.sv cpu.sv alu.sv decoder.sv executer.sv block_mem.sv writer.sv
xelab -debug typical test_cpu -s test_cpu.sim
xsim --runall test_cpu.sim

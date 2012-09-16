#!/bin/bash

# cleanup first
rm zstr.out
rm zstr.vcd

# list of source files
sources="../hdl/tbn/zstr_tb.sv ../hdl/tbn/zstr_src.sv ../hdl/tbn/zstr_drn.sv"

# compile verilog sources (testbench and RTL) and run simulation
iverilog -o zstr.out -g2009 $sources
vvp zstr.out

# open the waveform and detach it
gtkwave zstr.vcd gtkwave.sav &

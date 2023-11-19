#!/bin/sh

iverilog -o tb.vvp KF76489_Tone_Generator_tb.sv ../HDL/KF76489_Tone_Generator.sv ../HDL/KF76489_Attenuation.sv -g2012 -DIVERILOG
vvp tb.vvp
gtkwave tb.vcd


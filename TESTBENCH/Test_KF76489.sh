#!/bin/sh

iverilog -o tb.vvp KF76489_tb.sv ../HDL/KF76489.sv ../HDL/KF76489_Attenuation.sv ../HDL/KF76489_Bus_Control_Logic.sv ../HDL/KF76489_Noise_Generator.sv ../HDL/KF76489_Tone_Generator.sv -g2012 -DIVERILOG
vvp tb.vvp
gtkwave tb.vcd


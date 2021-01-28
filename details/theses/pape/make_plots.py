#!/usr/bin/env python3

from os import mkdir

from python.plot_fft_runtime import plot_fft_runtime
from python.plot_fft_flops import plot_fft_flops
from python.plot_rooflines import plot_rooflines
from python.plot_speedup import plot_speedup

try:
    mkdir("plots")
except FileExistsError:
    pass

plot_fft_runtime("smt")
plot_fft_runtime()
plot_fft_flops()
plot_rooflines("bare")
plot_rooflines()
plot_speedup()

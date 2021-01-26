# Diploma thesis on FFT performance

This directory contains data recorded for a diploma thesis on FFT performance on POWER and ARM, as
well as some scripts to generate plots out of the data.

The measurements were done on the following machines:

| Platform                      | **POWER**                 | **ARM**                   | **x86**               |
|-------------------------------|---------------------------|---------------------------|-----------------------|
| Cluster                       | Taurus (ZIH)              | Juawei (JSC)              | Hemera (HZDR)         |
| Processor                     | IBM POWER9 Monza          | HiSilicon Hi1616          | Intel Xeon Gold 6148  |
| Architecture                  |                           | Cortex-A72 (ARMv8-A)      | Skylake SP            |
| Cores                         | 22                        | 32                        | 20                    |
| Clock frequency               | 2.8 - 3.1 GHz             | 2.4 GHz                   | 2.4 - 3.1 GHz ¹       |
| Vector extensions             | AltiVec, VSX-3 (128 b)    | NEON (128 b)              | SSE, ..., AVX512 ²    |
| Theoretical peak performance  | 272.8 or 545.6 GFLOP/s ³  | 307.2 GFLOP/s             | 1408GFLOP/s ⁴         |
| Memory                        | DDR4 2666 MHz             | DDR4 2400 MHz             | DDR4 2666 MHz         |
| Compiler                      | GCC 8.3.0                 | GCC 9.2.0                 | GCC 7.3.0             |
| FFT libraries                 | ESSL 6.2, FFTW 3.3.8      | ArmPL 20.1.0, FFTW 3.3.8  | MKL 19.0, FFTW 3.3.8  |


¹ In normal mode (without AVX2/512)

² AVX512 was deactivated in FFTW, see [this issue](https://github.com/FFTW/fftw3/issues/143)

³ Using SMT-1, only one of the two vector units per core is available

⁴ At 2.2GHz turbo in AVX512 mode


## Generate plots

To generate the plots, run

```bash
./flops-csv.sh
./merge-cold-measurements.sh
./make_plots.py
```

This will create a directory called `plots`, containing PDFs.

To run the scripts you need `bash`, `awk`, `find` (findutils), `cube_info` (cube) and `python3` with
the libraries `numpy`, `scipy`, `matplotlib` and `pandas`


## Contents

The contents of this directory:

```
.
├── data → measurement data from gearshifft with and without Score-P attached
├── data-power9-smt* → measurement data from gearshifft on POWER9, using different SMT "settings"
├── ert-results → results from Empirical Roofline Tool (without raw measurement data)
│
├── common → common files for running jobs
├── for-* → platform-specific scripts for running jobs
│
├── flops-csv.sh               ↘
├── merge-cold-measurements.sh → scripts for generating intermediate data which is later used to create the plots
├── make_plots.py              ↗
├── cleanup.sh
│
├── matplotlibrc                     ↘
├── custom-ggplot.mplstyle           → configuration files for matplotlib
├── custom-ggplot-roofline.mplstyle  ↗
│
├── awk → awk scripts
└── python → python modules
```


## Acknowledgements

The authors gratefully acknowledge the access that was provided to the Huawei Prototype Cluster at
Forschungszentrum Jülich / Jülich Supercomputing Centre.

The authors would also like to thank the Centre for Information Services and High Performance
Computing (ZIH) at TU Dresden for granting access to the extension High Performance Computing -
Data Analytics (HPC-DA) of their High Performance Computing and Storage Complex (HRSK-II).

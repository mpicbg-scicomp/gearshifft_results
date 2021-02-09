#!/bin/bash
#SBATCH --partition=arm-hi1616
#SBATCH --exclusive
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=64

set -eo pipefail

NUM_CPUS=32
NUMA_NODES=2,3      # one socket has two NUMA nodes
WS="$HOME"
RESULTS="$WS/gearshifft-results"
SCRIPT_DIR="$WS/for-hi1616"

export OMP_NUM_THREADS="$NUM_CPUS"

source "$SCRIPT_DIR/modules"
source "$SCRIPT_DIR/../common/run-case"

mkdir -p "$RESULTS"

run_case hi1616 normal case1 armplfftw Fftw_ARMPL/double/*/Outplace_Real   estimate 01
run_case hi1616 normal case1      fftw       Fftw/double/*/Outplace_Real   estimate 01

run_case hi1616 normal case2 armplfftw Fftw_ARMPL/double/*/Inplace_Complex measure  01
run_case hi1616 normal case2      fftw       Fftw/double/*/Inplace_Complex measure  01

run_case hi1616 normal case3 armplfftw Fftw_ARMPL/double/*/Inplace_Real   estimate  01
run_case hi1616 normal case3      fftw       Fftw/double/*/Inplace_Real   estimate  01

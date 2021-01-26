#!/bin/bash
#SBATCH --partition=defq
#SBATCH --exclusive
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=80
#SBATCH --time=08:00:00
#SBATCH --mail-type=END
#SBATCH --mail-user=d.pape@hzdr.de

set -eo pipefail

NUM_CPUS=20
NUMA_NODES=1        # No. 1
WS="$HOME/ws_gearshifft"
RESULTS="$WS/gearshifft-results"
SCRIPT_DIR="$WS/for-skylake"

export OMP_NUM_THREADS="$NUM_CPUS"
export LD_LIBRARY_PATH="$HOME/.local/lib:$LD_LIBRARY_PATH"

source "$SCRIPT_DIR/modules"
source "$SCRIPT_DIR/../common/run-case"

mkdir -p "$RESULTS"

run_case skylake normal case1 fftwwrappers   Fftw_mkl_gnuwrapper/double/*/Outplace_Real   estimate  01
run_case skylake normal case1 fftw           Fftw/double/*/Outplace_Real                  estimate  01

run_case skylake normal case2 fftwwrappers   Fftw_mkl_gnuwrapper/double/*/Inplace_Complex measure   01
run_case skylake normal case2 fftw           Fftw/double/*/Inplace_Complex                measure   01

run_case skylake normal case3 fftwwrappers   Fftw_mkl_gnuwrapper/double/*/Inplace_Real   estimate   01
run_case skylake normal case3 fftw           Fftw/double/*/Inplace_Real                  estimate   01

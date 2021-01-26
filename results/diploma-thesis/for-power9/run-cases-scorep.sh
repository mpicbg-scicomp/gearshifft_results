#!/bin/bash
#SBATCH --account=p_gearshifft
#SBATCH --partition=ml
#SBATCH --exclusive
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=44
#SBATCH --gres=gpu:6
#SBATCH --time=01:00:00
#SBATCH --mail-type=END
#SBATCH --mail-user=david.pape@mailbox.tu-dresden.de

set -eo pipefail

NUM_CPUS=22
NUMA_NODES=8        # for some reason the CPU NUMA nodes are called 0 and 8
WS="/lustre/scratch2/ws/0/s6616380-gearshifft"
RESULTS="$WS/gearshifft-results"
SCRIPT_DIR="$WS/for-power9"

export OMP_NUM_THREADS="$NUM_CPUS"

source "$SCRIPT_DIR/modules"
source "$SCRIPT_DIR/../common/run-case"

mkdir -p "$RESULTS"

run_case power9 scorep case1 esslfftw Fftw_ESSL/double/*/Outplace_Real   estimate   01
run_case power9 scorep case1     fftw      Fftw/double/*/Outplace_Real   estimate   01

run_case power9 scorep case2 esslfftw Fftw_ESSL/double/*/Inplace_Complex measure    01
run_case power9 scorep case2     fftw      Fftw/double/*/Inplace_Complex measure    01

run_case power9 scorep case3 esslfftw Fftw_ESSL/double/*/Inplace_Real   estimate    01
run_case power9 scorep case3     fftw      Fftw/double/*/Inplace_Real   estimate    01

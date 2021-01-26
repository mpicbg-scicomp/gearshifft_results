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

n=0

while read -r exts; do
    c="case3-cold"
    f="$WS/common/extents-${c}.conf"
    ((n=n+1))

    echo "$exts" > "$f"

    for i in $(seq -w 1 20); do
        run_case power9 normal "$c" esslfftw Fftw_ESSL/double/*/Inplace_Real   estimate "$n-$i"
        run_case power9 normal "$c"     fftw      Fftw/double/*/Inplace_Real   estimate "$n-$i"
        run_case power9 scorep "$c" esslfftw Fftw_ESSL/double/*/Inplace_Real   estimate "$n-$i"
        run_case power9 scorep "$c"     fftw      Fftw/double/*/Inplace_Real   estimate "$n-$i"
    done

    rm -f "$f"

done < <(grep -vE "^(#|$)" "$WS/common/extents-case3.conf")

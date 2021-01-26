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

n=0

while read -r exts; do
    c="case3-cold"
    f="$WS/common/extents-${c}.conf"
    ((n=n+1))

    echo "$exts" > "$f"

    for i in $(seq -w 1 20); do
        run_case hi1616 normal "$c" armplfftw Fftw_ARMPL/double/*/Inplace_Real   estimate "$n-$i"
        run_case hi1616 normal "$c"      fftw       Fftw/double/*/Inplace_Real   estimate "$n-$i"
    done

    rm -f "$f"

done < <(grep -vE "^(#|$)" "$WS/common/extents-case3.conf")

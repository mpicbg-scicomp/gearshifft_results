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

n=0

while read -r exts; do
    c="case3-cold"
    f="$WS/common/extents-${c}.conf"
    ((n=n+1))

    echo "$exts" > "$f"

    for i in $(seq -w 1 20); do
        run_case skylake normal "$c" fftwwrappers Fftw_mkl_gnuwrapper/double/*/Inplace_Real   estimate "$n-$i"
        run_case skylake normal "$c" fftw                        Fftw/double/*/Inplace_Real   estimate "$n-$i"
        run_case skylake scorep "$c" fftwwrappers Fftw_mkl_gnuwrapper/double/*/Inplace_Real   estimate "$n-$i"
        run_case skylake scorep "$c" fftw                        Fftw/double/*/Inplace_Real   estimate "$n-$i"
    done

    rm -f "$f"

done < <(grep -vE "^(#|$)" "$WS/common/extents-case3.conf")

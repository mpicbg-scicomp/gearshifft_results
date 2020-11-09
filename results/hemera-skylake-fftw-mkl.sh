#!/bin/bash
#SBATCH --partition=defq
#SBATCH --exclusive
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --array=0-4
#SBATCH --cpus-per-task=80
#SBATCH --time=96:00:00
#SBATCH --output=hemera-skylake-%A-%a.out
#SBATCH --mail-type=all
#SBATCH --mail-user=d.pape@hzdr.de

set -e

module purge
module load gcc/9.1.0 boost/1.72.0 intel/19.0

export LD_LIBRARY_PATH="$HOME/.local/lib:$HOME/.local/lib64:$LD_LIBRARY_PATH"
export OMP_NUM_THREADS=80

RESULTS_DIR="$HOME/gearshifft-results-mpicbg-scicomp"
EXTENTS_DIR="$HOME/.local/share/gearshifft"
RIGOR="measure"
EXTENTS_FILES=("extents_capped_intel.conf" "extents_1d_fftw.conf" "extents_2d_publication.conf" "extents_3d_publication.conf")

mkdir -p "$RESULTS_DIR"
dim="$SLURM_ARRAY_TASK_ID"
extents="$EXTENTS_DIR/${EXTENTS_FILES[$dim]}"

case "$dim" in
    0)      stdbuf -o0 -e0 time srun gearshifft_fftwwrappers \
                -f "$extents" \
                --rigor "$RIGOR" \
                -o "$RESULTS_DIR/mkl19.0-${RIGOR}-gcc9.1.0-CentOS7-${SLURM_ARRAY_JOB_ID}.csv"
            ;;

    *)      stdbuf -o0 -e0 time srun gearshifft_fftw \
                -f "$extents" \
                --rigor "$RIGOR" \
                -o "$RESULTS_DIR/fftw3.3.8-${RIGOR}-${dim}d-gcc9.1.0-CentOS7-${SLURM_ARRAY_JOB_ID}.csv"
            ;;
esac

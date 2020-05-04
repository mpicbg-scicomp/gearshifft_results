#!/bin/bash
#SBATCH --partition=defq
#SBATCH --exclusive
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=40
#SBATCH --array 1-3
#SBATCH --time=18:00:00
##SBATCH --mail-type=all
##SBATCH --mail-user=

set -e

module purge
module load gcc/9.1.0 boost/1.72.0

RESULTS_DIR="$HOME/gearshifft_results"
N="$SLURM_ARRAY_TASK_ID"
EXTENTS="$HOME/.local/share/gearshifft/extents_${N}d_publication.conf"
RIGOR="estimate"

mkdir -p "$RESULTS_DIR"

srun gearshifft_fftw -f "$EXTENTS" \
                     --rigor "$RIGOR" \
                     -o "$RESULTS_DIR/fftw3.3.8_${N}d_${RIGOR}_gcc9.1.0_CentOS7_${SLURM_JOB_ID}.csv"

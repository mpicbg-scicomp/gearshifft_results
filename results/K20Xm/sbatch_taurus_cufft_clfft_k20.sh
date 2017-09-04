#!/bin/bash
#SBATCH -J gearshifftK20
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --time=12:00:00
#SBATCH --mem=48000M
#SBATCH --partition=gpu1
#SBATCH --exclusive
#SBATCH --array 1-2
#SBATCH -o slurmgpu1_array-%A_%a.out
#SBATCH -e slurmgpu1_array-%A_%a.err


k=$SLURM_ARRAY_TASK_ID

CURDIR=$HOME/cuda-workspace/gearshifft
RESULTSA=$HOME/cuda-workspace/gearshifft_results/results/K20Xm/cuda-8.0.61
RESULTSB=$HOME/cuda-workspace/gearshifft_results/results/K20Xm/clfft-2.12.2

# FEXTENTS1D=$CURDIR/share/gearshifft/extents_1d_publication.conf
# FEXTENTS2D=$CURDIR/share/gearshifft/extents_2d_publication.conf
# FEXTENTS3D=$CURDIR/share/gearshifft/extents_3d_publication.conf
# FEXTENTS=$CURDIR/share/gearshifft/extents_all_publication.conf
FEXTENTS=${CURDIR}/share/gearshifft/extents_capped_all_publication.conf

module purge
module load opencl boost/1.60.0-gnu5.3-intelmpi5.1 clFFT/2.12.2-cuda8.0-gcc5.3
module switch cuda/8.0.61
module unload mpirt
if [ $k -eq 1 ]; then
    mkdir -p ${RESULTSA}
    srun --cpu-freq=medium --gpufreq=2600:732 $CURDIR/release/gearshifft_cufft -f $FEXTENTS -o $RESULTSA/cufft_gcc5.3.0_RHEL6.8.csv
fi
if [ $k -eq 2 ]; then
    mkdir -p ${RESULTSB}
    srun --cpu-freq=medium --gpufreq=2600:732 $CURDIR/release_12/gearshifft_clfft -f $FEXTENTS -o $RESULTSB/clfft_gcc5.3.0_RHEL6.8.csv
fi
module list
nvidia-smi -q -d PERFORMANCE

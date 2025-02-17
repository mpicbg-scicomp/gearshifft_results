#!/bin/bash
#SBATCH -J gearshifftFFTW
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --time=110:00:00
#SBATCH --mem=61991M
#SBATCH --partition=haswell64
#SBATCH --exclusive
#SBATCH --array 0-5,7-9
#SBATCH -o slurmcpu_array-%A_%a.out
#SBATCH -e slurmcpu_array-%A_%a.err

k=$SLURM_ARRAY_TASK_ID

CURDIR=$HOME/cuda-workspace/gearshifft
REL=$CURDIR/release
RESULTS=$HOME/cuda-workspace/gearshifft_results/results/haswell/fftw3.3.6pl1
mkdir -p ${RESULTS}

FEXTENTS1D=$CURDIR/share/gearshifft/extents_1d_publication.conf
FEXTENTS1DFFTW=$CURDIR/share/gearshifft/extents_1d_fftw.conf  # excluded a few very big ones
FEXTENTS2D=$CURDIR/share/gearshifft/extents_2d_publication.conf
FEXTENTS3D=$CURDIR/share/gearshifft/extents_3d_publication.conf
FEXTENTS=$CURDIR/share/gearshifft/extents_all_publication.conf

module purge
module load opencl boost/1.60.0-gnu5.3-intelmpi5.1 clFFT/2.12.2-cuda8.0-gcc5.3 fftw/3.3.6pl1-gcc5.3-intelmpi5.1 gcc/5.3.0 cuda/8.0.61 cmake
module unload mpirt

if [ $k -eq 0 ]; then
#   srun $REL/gearshifft_fftw -f $FEXTENTS1D -o $RESULTS/fftw_estimate_gcc5.3.0_RHEL6.8.1d.csv --rigor estimate # got killed by OS (OOM error)
    srun --cpu-freq=medium $REL/gearshifft_fftw -f $FEXTENTS1DFFTW -o $RESULTS/fftw_estimate_gcc5.3.0_RHEL6.8.1d.csv --rigor estimate

elif [ $k -eq 1 ]; then
    srun --cpu-freq=medium $REL/gearshifft_fftw -f $FEXTENTS2D -o $RESULTS/fftw_estimate_gcc5.3.0_RHEL6.8.2d.csv --rigor estimate

elif [ $k -eq 2 ]; then
    srun --cpu-freq=medium $REL/gearshifft_fftw -f $FEXTENTS3D -o $RESULTS/fftw_estimate_gcc5.3.0_RHEL6.8.3d.csv --rigor estimate

elif [ $k -eq 3 ]; then
    srun --cpu-freq=medium $REL/gearshifft_fftw -f $FEXTENTS1DFFTW -o $RESULTS/fftw_wisdom_gcc5.3.0_RHEL6.8.1d.csv --rigor wisdom --wisdom_sp $CURDIR/share/gearshifft/fftwf_wisdom_3.3.6-pl1.txt --wisdom_dp $CURDIR/share/gearshifft/fftw_wisdom_3.3.6-pl1.txt

elif [ $k -eq 4 ]; then
    srun --cpu-freq=medium $REL/gearshifft_fftw -f $FEXTENTS2D -o $RESULTS/fftw_wisdom_gcc5.3.0_RHEL6.8.2d.csv --rigor wisdom --wisdom_sp $CURDIR/share/gearshifft/fftwf_wisdom_3.3.6-pl1.txt --wisdom_dp $CURDIR/share/gearshifft/fftw_wisdom_3.3.6-pl1.txt

elif [ $k -eq 5 ]; then
    srun --cpu-freq=medium $REL/gearshifft_fftw -f $FEXTENTS3D -o $RESULTS/fftw_wisdom_gcc5.3.0_RHEL6.8.3d.csv --rigor wisdom --wisdom_sp $CURDIR/share/gearshifft/fftwf_wisdom_3.3.6-pl1.txt --wisdom_dp $CURDIR/share/gearshifft/fftw_wisdom_3.3.6-pl1.txt

#elif [ $k -eq 6 ]; then
#     srun --cpu-freq=medium $REL/gearshifft_fftw -f $FEXTENTS1D -o $RESULTS/fftw_gcc5.3.0_RHEL6.8.1d.csv # takes too long, >7d
elif [ $k -eq 7 ]; then
     srun --cpu-freq=medium $REL/gearshifft_fftw -f $FEXTENTS2D -o $RESULTS/fftw_gcc5.3.0_RHEL6.8.2d.csv
elif [ $k -eq 8 ]; then
     srun --cpu-freq=medium $REL/gearshifft_fftw -f $FEXTENTS3D -o $RESULTS/fftw_gcc5.3.0_RHEL6.8.3d.csv
elif [ $k -eq 9 ]; then
     srun --cpu-freq=medium $REL/gearshifft_fftw -f $FEXTENTS1DFFTW -o $RESULTS/fftw_gcc5.3.0_RHEL6.8.1d.csv
fi

module list

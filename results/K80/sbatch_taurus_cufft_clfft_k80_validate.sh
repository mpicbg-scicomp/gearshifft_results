#!/bin/bash
#SBATCH -J gearshifft_K80_Verify
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --time=1:00:00
#SBATCH --mem=4000M # gpu2
#SBATCH --partition=gpu2
#SBATCH --exclusive

RESULTS=$HOME/cuda-workspace/gearshifft_results/results/K80/cuda-8.0.61
GEARSHIFFT=$HOME/cuda-workspace/gearshifft/release
GEARSHIFFT_VAL=$HOME/cuda-workspace/gearshifft/validation/cufft_standalone/build/

# gearshifft
FCONFIG=$HOME/cuda-workspace/gearshifft/share/gearshifft/cufft_validate.conf
>$FCONFIG

module purge
module load opencl boost/1.60.0-gnu5.3-intelmpi5.1 clFFT/2.12.2-cuda8.0-gcc5.3 fftw/3.3.6pl1-gcc5.3-intelmpi5.1 gcc/5.3.0 cuda/8.0.61 cmake
module unload mpirt
module switch cuda/8.0.61

for r in `seq 1 250`; do
    # 1<<26
    echo 16777216 >> $FCONFIG
done
srun --cpu-freq=medium --gpufreq=2505:823 $GEARSHIFFT/gearshifft_cufft -f $FCONFIG -r */float/*/Inplace_Real -o $RESULTS/validate_cufft_r2c_inplace_RHEL6.8.csv

>$FCONFIG
for r in `seq 1 250`; do
    echo 1024 >> $FCONFIG
done

srun --cpu-freq=medium --gpufreq=2505:823 $GEARSHIFFT/gearshifft_cufft -f $FCONFIG -r */float/*/Inplace_Real -o $RESULTS/validate_cufft_r2c_inplace_small_RHEL6.8.csv

# cufft standalone
iterations=250

runs=10
FCUFFT="$RESULTS/validate_cufft_standalone_r2c_inplace_RHEL6.8.csv"
FCUFFT_SMALL="$RESULTS/validate_cufft_standalone_r2c_inplace_small_RHEL6.8.csv"
srun --cpu-freq=medium --gpufreq=2505:823 $GEARSHIFFT_VAL/cufft_time_r2c 16777216 $iterations $FCUFFT $runs 1
srun --cpu-freq=medium --gpufreq=2505:823 $GEARSHIFFT_VAL/cufft_time_r2c 1024 $iterations $FCUFFT_SMALL $runs 1

FCUFFT="$RESULTS/validate_cufft_standalone_r2c_tts_inplace_RHEL6.8.csv"
FCUFFT_SMALL="$RESULTS/validate_cufft_standalone_r2c_tts_inplace_small_RHEL6.8.csv"
srun --cpu-freq=medium --gpufreq=2505:823 $GEARSHIFFT_VAL/cufft_time_r2c 16777216 $iterations $FCUFFT $runs 0
srun --cpu-freq=medium --gpufreq=2505:823 $GEARSHIFFT_VAL/cufft_time_r2c 1024 $iterations $FCUFFT_SMALL $runs 0

#!/bin/bash
#SBATCH -J gearshifft-gtx1080
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --time=10:00:00
#SBATCH --mem=128000M # gpu2
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --array 1-2
#SBATCH -o gearshifft-gtx1080_array-%A_%a.out
#SBATCH -e gearshifft-gtx1080_array-%A_%a.err

k=$SLURM_ARRAY_TASK_ID

CURDIR=${HOME}/development/gearshifft_results
APPROOT=${HOME}/development/gearshifft
RESULTSA=${CURDIR}/results/GTX1080/cuda-8.0.61
RESULTSB=${CURDIR}/results/GTX1080/clfft-2.12.2

FEXTENTS1D=$CURDIR/share/gearshifft/extents_1d_publication.conf
FEXTENTS2D=$CURDIR/share/gearshifft/extents_2d_publication.conf
FEXTENTS3D=$CURDIR/share/gearshifft/extents_3d_publication.conf
#FEXTENTS=$CURDIR/share/gearshifft/extents_all_publication.conf
FEXTENTS=${APPROOT}/share/gearshifft/extents_capped_all_publication.conf

module load cuda/8.0.61 clfft/2.12.2 fftw/3.3.6-pl1-brdw boost/1.63.0
module unload gcc
module load gcc/5.3.0

if [[ -z ${FEXTENTS} ]];
then
echo "uups, ${FEXTENTS} is empty"
fi

if [[ ! -e ${FEXTENTS} ]];
then
echo "uups, ${FEXTENTS} does not exist"
else
echo "running benchmarks from configuration" `ls $FEXTENTS`
fi


echo -e "results stored to \n->$RESULTSA/cufft_gcc5.3.0_centos7.2.csv\n->$RESULTSB/clfft_gcc5.3.0_centos7.2.csv"
# default is cuda 8.0.61
if [ $k -eq 1 ]; then
    mkdir -p ${RESULTSA}
    srun $APPROOT/build/gearshifft_cufft -f $FEXTENTS -o $RESULTSA/cufft_gcc5.3.0_centos7.2.csv
fi
if [ $k -eq 2 ]; then
    mkdir -p ${RESULTSB}
    srun  $APPROOT/build/gearshifft_clfft -f $FEXTENTS -o $RESULTSB/clfft_gcc5.3.0_centos7.2.csv
fi

module list
nvidia-smi -q -d PERFORMANCE

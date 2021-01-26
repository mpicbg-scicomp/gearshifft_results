#!/bin/bash
#SBATCH --account=p_gearshifft
#SBATCH --partition=ml
#SBATCH --exclusive
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=176
#SBATCH --gres=gpu:6
#SBATCH --time=01:00:00

set -eo pipefail

function cpuList {
    start=$1
    numCpus=$2
    threadsPerCpu=$3
    maxThreadsPerCpu=$4

    for offset in $(seq 0 $((threadsPerCpu - 1))); do
        for cpu in $(seq 0 $((numCpus - 1))); do
            echo $((start + offset + cpu * maxThreadsPerCpu))
        done
    done | paste -sd,
}

FIRST_CPU_NUM=88
NUM_CORES=22
MIN_THREADS_PER_CORE=1
MAX_THREADS_PER_CORE=4
NUM_RUNS=20
FILE="babelstream-double-${SLURM_JOB_ID}.csv"
RESULT_DIR="$HOME/ws_gearshifft/babelstream-results"

module --force purge && module load modenv/ml && module load GCC/8.3.0

mkdir -p "$RESULT_DIR"
pushd /tmp

rm -rf BabelStream
git clone "https://github.com/UoB-HPC/BabelStream.git"
cd BabelStream

make -f OpenMP.make COMPILER=GNU_PPC TARGET=CPU

echo "function,num_times,n_elements,sizeof,max_mbytes_per_sec,min_runtime,max_runtime,avg_runtime,run,threads_per_core" | tee "$FILE"

for threadsPerCore in $(seq $MIN_THREADS_PER_CORE $MAX_THREADS_PER_CORE); do

    export OMP_NUM_THREADS=$((threadsPerCore * NUM_CORES))
    cpus=$(cpuList $FIRST_CPU_NUM $NUM_CORES "$threadsPerCore" $MAX_THREADS_PER_CORE)

    for run in $(seq $NUM_RUNS); do
        numactl --localalloc --physcpubind="$cpus" ./omp-stream --csv -n 2 -s 250000000 |
            tail -n +2 |
            awk -v run="$run" -v tpc="$threadsPerCore" '{ print $0 "," run "," tpc }' |
            tee -a "$FILE"
    done

done

mv "$FILE" "$RESULT_DIR"

popd

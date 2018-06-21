#!/bin/bash
# taurus GPU test node

LIB_VERSION=$1 # e.g. cuda-8.0.61
PLATFORM=$2 # V100, P100, GV100
CSV_ADD_TO_FILENAME="gcc5.3.0_SL7.4" # taurus GPU test node setting

GEARSHIFFT_ROOT=${HOME}/cuda-workspace/gearshifft
GEARSHIFFT_RESULTS_ROOT=${HOME}/cuda-workspace/gearshifft_results
RESULTS_PATH=${GEARSHIFFT_RESULTS_ROOT}/results/${PLATFORM}/${LIB_VERSION}
BUILD_PATH=${GEARSHIFFT_ROOT}/_build/${PLATFORM}-${LIB_VERSION}
FFT_EXTENTS_FILE=${GEARSHIFFT_ROOT}/share/gearshifft/extents_all_publication.conf
[[ ${LIB_VERSION} == "cuda"* ]] && FFT_LIB=cufft || FFT_LIB=clfft
RESULTS_FILE=${RESULTS_PATH}/${FFT_LIB}_${CSV_ADD_TO_FILENAME}.csv

# CUDA device indices on Taurus test node
# 0 = GV100 (socket 0)
# 1 = V100 (socket 1)
# 2 = P100 (socket 1)
# nvidia-smi device indices on Taurus test node
# 0 = GV100 (socket 0)
# 1 = P100 (socket 1)
# 2 = V100 (socket 1)

# set clock settings
if [[ $PLATFORM == "GV100" ]]; then
    CUDA_DEV=0
    NV_DEV=0
    DEV_SOCKET=0
    nvidia-smi -i $NV_DEV -ac 850,1327   # GV100
elif [[ $PLATFORM == "P100" ]]; then
    CUDA_DEV=2
    NV_DEV=1
    DEV_SOCKET=1
    nvidia-smi -i $NV_DEV -ac 715,1189   # P100
elif [[ $PLATFORM == "V100" ]]; then
    CUDA_DEV=1
    NV_DEV=2
    DEV_SOCKET=1
    nvidia-smi -i $NV_DEV -ac 877,1245   # V100
else
    echo "Unsupported Platform on Taurus."
    exit 127
fi

echo "<Configuration>"
echo "FFT Library  -> ${FFT_LIB}"
echo "Platform     -> ${PLATFORM}"
echo "Results file -> ${RESULTS_FILE}"

# check clock and device index settings
echo "<Show Clock Settings>"
module load read-nvml-clocks-pci
read-nvml-clocks-pci

# build + execute

mkdir -p ${RESULTS_PATH}
mkdir -p ${BUILD_PATH}

cd ${BUILD_PATH}

echo "<Build>"
module purge
module load boost/1.65.1-gnu5.5 cmake git clFFT/2.12.2-cuda8.0-gcc5.3
if [[ ${LIB_VERSION} = "cuda"* ]]; then
    MODULE_VERSION=${LIB_VERSION/cuda-/}
    module load cuda/${MODULE_VERSION}
    GEARSHIFFT_CLI_DEVICE="$CUDA_DEV"
else
    GEARSHIFFT_CLI_DEVICE='"0:'${CUDA_DEV}'"'
fi

export CMAKE_PREFIX_PATH=${CLFFT_ROOT}:${CUDA_INC}
make clean
rm -rf CMakeCache.txt CMakeFiles cmake_install.cmake Makefile
cmake ../.. -DGEARSHIFFT_FLOAT16_SUPPORT=ON || exit 1
make half-code || exit 1
make gearshifft_${FFT_LIB} || exit 1

echo "<Execute>"
module list 
${BUILD_PATH}/gearshifft_${FFT_LIB} -l
# run
RUN="numactl -m${DEV_SOCKET} -N${DEV_SOCKET} ${BUILD_PATH}/gearshifft_${FFT_LIB} -d ${GEARSHIFFT_CLI_DEVICE} -f ${FFT_EXTENTS_FILE} -o ${RESULTS_FILE}"
echo $RUN
eval $RUN
# show throttle reasons
nvidia-smi -i $NV_DEV -q -d PERFORMANCE
# reset app clocks
nvidia-smi -i $NV_DEV -rac

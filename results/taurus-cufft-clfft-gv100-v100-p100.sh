
LAUNCHER_FILE=${HOME}/cuda-workspace/gearshifft_results/results/taurus-cufft-clfft-gv100-v100-p100-launcher.sh

bash $LAUNCHER_FILE cuda-8.0.61 P100

bash $LAUNCHER_FILE cuda-9.0.176 P100
bash $LAUNCHER_FILE cuda-9.1.85 P100
bash $LAUNCHER_FILE cuda-9.2.88 P100

bash $LAUNCHER_FILE cuda-9.0.176 V100
bash $LAUNCHER_FILE cuda-9.1.85 V100
bash $LAUNCHER_FILE cuda-9.2.88 V100

bash $LAUNCHER_FILE cuda-9.0.176 GV100
bash $LAUNCHER_FILE cuda-9.1.85 GV100
bash $LAUNCHER_FILE cuda-9.2.88 GV100

bash $LAUNCHER_FILE clfft-2.12.2 P100
bash $LAUNCHER_FILE clfft-2.12.2 V100
bash $LAUNCHER_FILE clfft-2.12.2 GV100

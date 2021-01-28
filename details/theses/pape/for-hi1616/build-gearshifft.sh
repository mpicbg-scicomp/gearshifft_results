#!/bin/bash
#SBATCH --partition=arm-hi1616
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4

WS="$HOME"
SCRIPT_DIR="$WS/for-hi1616"

source "$SCRIPT_DIR/modules"
source "$SCRIPT_DIR/../common/build-gearshifft"

#!/bin/bash
#SBATCH --partition=defq
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4

WS="$HOME/ws_gearshifft"
SCRIPT_DIR="$WS/for-skylake"

source "$SCRIPT_DIR/modules"
source "$SCRIPT_DIR/../common/build-gearshifft"

#!/bin/bash
#SBATCH --account=p_gearshifft
#SBATCH --partition=ml
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=00:20:00

WS="/lustre/scratch2/ws/0/s6616380-gearshifft"
SCRIPT_DIR="$WS/for-power9"

source "$SCRIPT_DIR/modules"
source "$SCRIPT_DIR/../common/build-gearshifft"

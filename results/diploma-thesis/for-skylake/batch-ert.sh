#!/bin/bash
#SBATCH --partition=defq
#SBATCH --exclusive
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=80
#SBATCH --cpu-freq=3700000
#SBATCH --time=12:00:00
#SBATCH --mail-type=END
#SBATCH --mail-user=d.pape@hzdr.de

set -e

WS="$HOME/ws_gearshifft"
SCRIPT_DIR="$WS/for-skylake"

source "$SCRIPT_DIR/modules"

cd "$WS"
mkdir -p ert-results
./cs-roofline-toolkit/Empirical_Roofline_Tool-1.1.0/ert --no-post for-skylake/ert-skylake.conf

# to post-process, run
# ./cs-roofline-toolkit/Empirical_Roofline_Tool-1.1.0/ert --post-only for-skylake/ert-skylake.conf

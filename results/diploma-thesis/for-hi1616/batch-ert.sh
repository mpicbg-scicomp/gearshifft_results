#!/bin/bash
#SBATCH --partition=arm-hi1616
#SBATCH --exclusive
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=64
#SBATCH --cpu-freq=2400000
#SBATCH --exclude=juawei-a17
#SBATCH --mail-type=END
#SBATCH --mail-user=d.pape@hzdr.de

set -e

WS="$HOME"
SCRIPT_DIR="$WS/for-hi1616"

source "$SCRIPT_DIR/modules"

cd "$WS"
mkdir -p ert-results
./cs-roofline-toolkit/Empirical_Roofline_Tool-1.1.0/ert --no-post for-hi1616/ert-hi1616.conf

# to post-process, run
# ./cs-roofline-toolkit/Empirical_Roofline_Tool-1.1.0/ert --post-only for-hi1616/ert-hi1616.conf

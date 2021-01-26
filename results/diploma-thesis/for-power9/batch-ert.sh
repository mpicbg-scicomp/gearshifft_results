#!/bin/bash
#SBATCH --account=p_gearshifft
#SBATCH --partition=ml
#SBATCH --exclusive
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=176
#SBATCH --gres=gpu:6
#SBATCH --cpu-freq=3100000
#SBATCH --time=1-00:00:00
#SBATCH --mail-type=END
#SBATCH --mail-user=david.pape@mailbox.tu-dresden.de

set -e

WS="/lustre/scratch2/ws/0/s6616380-gearshifft"
SCRIPT_DIR="$WS/for-power9"

source "$SCRIPT_DIR/modules"

cd "$WS"
mkdir -p ert-results
./cs-roofline-toolkit/Empirical_Roofline_Tool-1.1.0/ert --no-post for-power9/ert-POWER9.conf

# to post-process, run
# ./cs-roofline-toolkit/Empirical_Roofline_Tool-1.1.0/ert --post-only for-power9/ert-POWER9.conf


#!/bin/bash

set -e

find data -mindepth 1 -type d -exec \
    bash -o pipefail -c \
       'if [[ $1 =~ "cold" ]]; then numIDs=1; else numIDs=5; fi;
        cube_info -m PAPI_DP_OPS "$1/profile.cubex" | ./awk/cube-to-csv.awk  | ./awk/multi-to-one.awk -v num_ids="$numIDs" > "$1-flops.csv"' \
            _ {} \;

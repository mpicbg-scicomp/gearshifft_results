#!/bin/bash

set -eo pipefail

pushd data >& /dev/null

rm -f "*.merged.csv"

find . -name "*cold*.csv" -not -name "*flops*" -exec \
    sh -c  'fn=$1;
            fnNew=${fn%-*-*}.merged.csv;
            test -f "$fnNew";
            keepHeader="$?";
            awk -v id="${fn:(-8):1}" -v run="${fn:(-6):2}" -v keep_header="$keepHeader" -- \
                "BEGIN { FS=\",\"; OFS=\",\" } \
                /^;/ { next } \
                keep_header == 1 { print; keep_header = 0 } \
                \$10 == 0 && \$11 == 0 { \$10=run+0; \$11=id+0; print }" $1 >> $fnNew' _ {} \;

find . -name "*cold*flops.csv" -exec \
    sh -c  'fn=$1;
            fnNew=${fn%-*-*-*}-flops.merged.csv;
            test -f "$fnNew";
            keepHeader="$?";
            awk -v id="${fn:(-14):1}" -v run="${fn:(-12):2}" -v keep_header="$keepHeader" -- \
                "BEGIN { FS=\",\"; OFS=\",\" } \
                keep_header == 1 { print; keep_header = 0 } \
                \$1 == 0 && \$2 == 0 { \$1=id; \$2=run; print }" $1 >> $fnNew' _ {} \;

popd >& /dev/null

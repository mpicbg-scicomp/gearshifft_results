#!/bin/bash

set -e

pushd data >& /dev/null

rm -f *-flops.csv
rm -f *.merged.csv

popd >& /dev/null

#!/bin/bash

set -e

find -L . \( -name "*-flops.csv" -o -name "*.merged.csv" \) -delete
find . -type d -name "plots" -exec rm -rf {} \;

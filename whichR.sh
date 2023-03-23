#!/bin/bash

# Figures R version
# Hanno 2023


set -e
INST_DIR=~/opt/bin
RVER=$(readlink "$INST_DIR/Rroot")

if [[ ! -d "$RVER" ]]; then
  echo "$RVER dosn't exists. Did you run buildR.sh?"
  exit 1
fi

echo "Selected R version is '$(basename -- $RVER)' in:"
echo $RVER

#!/bin/bash

# Figures R version
# Hanno 2023


set -e
INST_DIR=~/opt/bin
R_ROOT=$(readlink "$INST_DIR/Rroot")

if [[ ! -d "$R_ROOT" ]]; then
  echo "$R_ROOT dosn't exists. Did you run buildR.sh?"
  exit 1
fi

echo "Selected R version is '$(basename -- $R_ROOT)'":
echo "Rroot -> ${R_ROOT}"
echo "Rlibrary -> $(readlink ${INST_DIR}/Rlibrary)"
echo "Rsrc -> $(readlink ${INST_DIR}/Rsrc)"

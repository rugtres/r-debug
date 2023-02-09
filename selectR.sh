#!/bin/bash

# R version selector
# Hanno 2023

INST_DIR="$HOME/opt"

set -e
if [ -z $1 ]; then
    echo usage: ./select.sh Name
    exit 1
fi
PREFIX="$INST_DIR/$1"
if [ ! -d $PREFIX ]; then
    echo "$PREFIX doesn't exists. Bailing out"
    exit 1
fi

# fix symlinks
ln -sf ${HOME}/.R/${1}/Makevars ${HOME}/.R/Makevars
ln -sf ${PREFIX}/bin/R ${INST_DIR}/bin/R
ln -sf ${PREFIX}/bin/Rscript ${INST_DIR}/bin/Rscript

#!/bin/bash

# R version selector
# Hanno 2023

SH_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
INST_DIR="$HOME/opt"

set -e
if [ -z $1 ]; then
    echo usage: select.sh Name
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
rm -f ${INST_DIR}/bin/Rroot
ln -sf ${PREFIX}/ ${INST_DIR}/bin/Rroot
rm -f ${INST_DIR}/bin/Rlibrary
ln -sf ${PREFIX}/lib/R/library/ ${INST_DIR}/bin/Rlibrary
rm -f ${INST_DIR}/bin/Rsrc
ln -sf ${SH_DIR}/build/${1}/src/ ${INST_DIR}/bin/Rsrc

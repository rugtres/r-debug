#!/bin/bash

# buildOpenBLAS.sh
#
# Hanno 2023

set -a

PROFILE="$HOME/.bashrc"
INST_DIR="$HOME/opt"

if [ ! -d ./tmp ]; then
    mkdir ./tmp
fi
cd ./tmp
if [ ! -d ./OpenBLAS ]; then
    git clone --branch develop git@github.com:xianyi/OpenBLAS.git
    cd OpenBLAS
else
    cd OpenBLAS
    git pull
fi

export FC=gfortran
export DYNAMIC_ARCH=0
export USE_OPENMP=1
export USE_THREAD=1
export NUM_THREADS=$(nproc)
export USE_TLS=1
export PREFIX="$INST_DIR"
export LIBNAMESUFFIX=omp
make -j
make install

# Testing (optional)
# make -j lapack-test
# cd ./lapack-netlib; python3 ./lapack_testing.py -r -b TESTING

# add some stuff to $PROFILE
if [[ $( cat $PROFILE | grep -c "^# buildOpenBLAS.sh") -eq "0" ]]; then
    echo >> $PROFILE
    echo '# buildOpenBLAS.sh' >> $PROFILE
    echo "export OMP_NUM_THREADS=$(nproc)" >> $PROFILE
fi

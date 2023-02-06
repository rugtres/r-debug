#!/bin/bash

# filename: dummy.sh
# author: @Hanno

INST_DIR="$HOME/opt"
R_VERSION="4.2.2"       # default

# OpenBLAS injection
RBLASLIB="$INST_DIR/lib/R/lib/libRblas.so"
RLAPACKLIB="$INST_DIR/lib/R/lib/libRlapack.so"
OPENBLASLIB="$INST_DIR/lib/libopenblas_omp.so"  # includes LAPACK

export CC="gcc"
export CXX="g++"
export FC="gfortran"

# based on R CMD config <X>FLAGS:
CFLAGS="-fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -Wall"
CXXFLAGS="-fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -Wall"
FCFLAGS="-fstack-protector-strong -Wall"
OPTFLAGS=""

CONFIG="LIBnn=lib --disable-nls --enable-BLAS-shlib --enable-R-shlib --enable-memory-profiling"
OPTCONFIG=""

export R_BATCHSAVE="--no-save --no-restore"

R_DAILY="https://stat.ethz.ch/R/daily/"         # daily r-devel
R_BASE="https://cran.r-project.org/src/base/"   # official release
R_MIRROR="https://cran.uni-muenster.de/"        # CRAN mirror


usage() {
cat << EOF  
Usage: $0 -R <R version> [-chtio]
-h      Display help
-c      Use clang
-t      build type: debug|release|native
-i      instrumentation: valgrind
-o      link against OpenBLAS
-R      R version, "devel" or full version e.g. 4.2.1, defaults to ${R_VERSION}
EOF
}


exit_error() {
    if [ -z "$1" ]; then
        usage
    else
        echo "Error: ${1}"
    fi
    exit 1
}


r_major () {
    echo ${1:0:1}
}


while getopts ":hct:oR:" option; do
   case $option in
      h) usage
         exit
         ;;
      o) if [ ! -f "$OPENBLASLIB" ]; then
            exit_error "$OPENBLASLIB not found. Use buildOpenBLAS.sh to build it"
         fi
         openblas=1
         OPTCONFIG=$OPTCONFIG --with-blas="$INST_DIR/opt/lib -lopenblas-omp" 
         OPTCONFIG=$OPTCONFIG --with-lapack="$INST_DIR/opt/lib -lopenblas-omp"
         ;;
      c) export CC="clang"
         export CXX="clang++"
         ;;
      t) case $OPTARG in
            release) OPTFLAGS="${OPTFLAGS} -g -O2";;
            native) OPTFLAGS="${OPTFLAGS} -g -O2 -march=native -pthread -fopenmp";;
            debug) OPTFLAGS="${OPTFLAGS} -g -O0";;
            *) exit_error "Invalid build type";;
         esac
         build_type=$OPTARG
         ;;
      i) case $OPTARG in
            valgrind) OPTCONFIG="-C --with-valgrind-instrumentation=2 --with-system-valgrind-headers";;
            *) exit_error "Invalid instrumentation";;
         esac
         inst_type=$OPTARG
         ;;
      R) if [ $(echo $OPTARG | grep -oP "(\d\.\d\.\d)|(devel)") ]; then
            R_VERSION=$OPTARG
         else
            exit_error "mangled R version '${OPTARG}'"
         fi
         ;;
     \?) # Invalid option 
         exit_error "Invalid option"
         ;;
   esac
done

# choose r-devel or r-base source tree
if [ "$R_VERSION" == "devel" ]; then
    R_SRC="${R_DAILY}R-devel.tar.gz"
else
    R_SRC="${R_BASE}R-$(r_major $R_VERSION)/R-${R_VERSION}.tar.gz"
fi

if [ -z "$build_type" ]; then
    exit_error "No build type given"
else
    if [ "$build_type" != "native" ] && [ ! -z $openblas ]; then
        exit_error "-o (openblas) only supported for 'native' build"
    fi
fi

export CFLAGS="${CFLAGS} ${OPTFLAGS}"
export CXXFLAGS="${CXXFLAGS} ${OPTFLAGS}"
export FCFLAGS="${FCFLAGS} ${OPTFLAGS}"

echo "$CC: $CFLAGS"
echo "$CXX: $CXXFLAGS"
echo "$FC: $FCFLAGS"
echo "configure: $CONFIG $OPTCONFIG"

# pull source tree into ./tmp/r-source
if [ ! -d ./tmp ]; then
    mkdir ./tmp
fi
cd ./tmp
wget $R_SRC -O "$R_VERSION.tar.gz"
tar -xf "$R_VERSION.tar.gz"

cd "R-$R_VERSION"
./configure --prefix=$INST_DIR $CONFIG $OPTCONFIG
# make clean
make --jobs=$(nproc) 
make install

if [ ! -z "$openblas" ]; then
    # move native libRblas & libRlapack
    mv ${RBLASLIB} ${RBLASLIB}.backup
    mv ${RLAPACKLIB} ${RLAPACKLIB}.backup
    # create symlinks to OpenBLAS
    ln -s ${OPENBLASLIB} ${RBLASLIB}
    ln -s ${OPENBLASLIB} ${RLAPACKLIB}
fi

# add some packages
$INST_DIR/bin/R -e "install.packages(c('devtools', 'Rcpp', 'SuppDists'), threads=$(nproc), repos='${R_MIRROR}')"

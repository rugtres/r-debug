#!/bin/bash

# filename: buildR.sh
# author: @Hanno

PREFIX="$HOME/opt"
INST_DIR=$PREFIX
R_NAME=""
R_VERSION="4.2.2"       # default
OPENBLASLIB="$INST_DIR/lib/libopenblas_omp.so"  # includes LAPACK

# better these exists:
mkdir -p $INST_DIR/bin
mkdir -p $INST_DIR/lib
mkdir -p $INST_DIR/share

export CC="gcc"
export CXX="g++"
export FC="gfortran"
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

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
Usage: $0 -N name -R <R version> -S <suffix> [-chtio]
-h      Display help
-c      Use clang
-t      Build type: debug|release|native
-i      Instrumentation: valgrind
-o      link against OpenBLAS
-N      Name
-R      R version, "devel" or full version e.g. 4.2.1, defaults to ${R_VERSION}
-S      Suffix
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


while getopts ":hct:i:oR:N:" option; do
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
            release) OPTFLAGS="${OPTFLAGS} -g -O2"
            ;;
            native) OPTFLAGS="${OPTFLAGS} -g -O2 -march=native -pthread -fopenmp"
            ;;
            debug) OPTFLAGS="${OPTFLAGS} -g -O0"
            ;;
            *) exit_error "Invalid build type"
            ;;
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
      N) R_NAME=$OPTARG
         ;;
     \?) # Invalid option 
         exit_error "Invalid option"
         ;;
   esac
done

if [ -z "$R_NAME" ]; then
    exit_error "please provide a name (-N)"
fi

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

INST_DIR="${INST_DIR}/${R_NAME}"
export CFLAGS="${CFLAGS} ${OPTFLAGS}"
export CXXFLAGS="${CXXFLAGS} ${OPTFLAGS}"
export FCFLAGS="${FCFLAGS} ${OPTFLAGS}"

echo Bulding R with:
echo "$CC: $CFLAGS"
echo "$CXX: $CXXFLAGS"
echo "$FC: $FCFLAGS"
echo "configure: $CONFIG $OPTCONFIG"

# pull source tree into ./tmp/r-source
if [ ! -d ./.tmp ]; then
    mkdir ./.tmp
fi
cd ./.tmp
if [ -d "R-$R_VERSION" ]; then
    # clobber old build
    rm -rf "R-$R_VERSION"
fi
wget $R_SRC -O "$R_VERSION.tar.gz"
tar -xf "$R_VERSION.tar.gz"

cd "R-$R_VERSION"
./configure --prefix=$INST_DIR $CONFIG $OPTCONFIG
# make clean
make --jobs=$(nproc)
if [ -d $INST_DIR ]; then
    # clobber old install
    rm -rf $INST_DIR
fi
make install

# Create $HOME/.R/xxxx/Makevars
if [ -d "${HOME}/.R/${R_NAME}" ]; then
    rm -rf ${HOME}/.R/${R_NAME}
fi
mkdir -p "$HOME/.R/$R_NAME"
echo CC=${CC} > ${HOME}/.R/${R_NAME}/Makevars
echo CXX=${CXX} >> ${HOME}/.R/${R_NAME}/Makevars
echo CFLAGS= ${CFLAGS} >> ${HOME}/.R/${R_NAME}/Makevars
echo CXXFLAGS=${CXXFLAGS} >> ${HOME}/.R/${R_NAME}/Makevars
ln -sf ${HOME}/.R/${R_NAME}/Makevars ${HOME}/.R/Makevars

# symlink R binaries
ln -sf "$INST_DIR/bin/R" "$PREFIX/bin/R"
ln -sf "$INST_DIR/bin/Rscript" "$PREFIX/bin/Rscript"

# OpenBLAS injection
RBLASLIB="$INST_DIR/lib/R/lib/libRblas.so"
RLAPACKLIB="$INST_DIR/lib/R/lib/libRlapack.so"
if [ ! -z "$openblas" ]; then
    # move native libRblas & libRlapack
    mv ${RBLASLIB} ${RBLASLIB}.backup
    mv ${RLAPACKLIB} ${RLAPACKLIB}.backup
    # create symlinks to OpenBLAS
    ln -sf ${OPENBLASLIB} ${RBLASLIB}
    ln -sf ${OPENBLASLIB} ${RLAPACKLIB}
fi

# add some 'common' packages
Rscript -e "install.packages(c('BH' 'R6', 'jsonlite', 'Rcpp'), repos='${R_MIRROR}')"
Rscript -e "install.packages(c('devtools', 'remotes', 'magrittr', 'SuppDists'), repos='${R_MIRROR}')"

# add vscode support packages
# pull from github to get the newest versions
RVSCODE="\
library('remotes');\
remotes::install_github('REditorSupport/languageserver');\
remotes::install_github('ManuelHentschel/vscDebugger');\
remotes::install_github('nx10/httpgd');\
"
Rscript -e $RVSCODE

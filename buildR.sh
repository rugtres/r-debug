#!/bin/bash

# filename: buildR.sh
# author: @Hanno

SH_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PREFIX="$HOME/opt"
BUILD_DIR="${SH_DIR}/build"
INST_DIR=$PREFIX
R_NAME=""
R_VERSION="4.3.1"       # default
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

CFLAGS="-Wall -pthread -fopenmp"
CXXFLAGS="-Wall -pthread -fopenmp"
FCFLAGS="-Wall -pthread -fopenmp"
OPTFLAGS="-g"           # overridden if clang
OPTLDFLAGS="-pthread"   # overridden if clang

CONFIG="LIBnn=lib --disable-nls --enable-BLAS-shlib --enable-R-shlib"
OPTCONFIG=""

export R_BATCHSAVE="--no-save --no-restore"

R_DAILY="https://stat.ethz.ch/R/daily/"         # daily r-devel
R_BASE="https://cran.r-project.org/src/base/"   # official release
R_MIRROR="http://cran.uni-muenster.de/"        # CRAN mirror


usage() {
cat << EOF  
Usage: $0 -N name -R <R version> -S <suffix> [-chtio]
-h      Display help
-c      Use clang
-t      Build type: debug|release|tune|native|opt
-i      Instrumentation: valgrind|profile|valgrind2
-o      Link against OpenBLAS
-N      Name
-R      R version, "devel" or full version e.g. 4.2.1, defaults to ${R_VERSION}
-S      Suffix
-q      Don't build, just check
EOF
}


get_abs_filename() {
  # $1 : relative filename
  echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}


exit_error() {
    if [ -z "$1" ]; then
        usage
    else
        echo "Error: ${1}"
        usage
    fi
    exit 1
}


r_major () {
    echo ${1:0:1}
}

# collect options
while getopts ":hcqt:i:oR:N:" option; do
   case $option in
      h) usage
         exit
         ;;
      o) if [ ! -f "$OPENBLASLIB" ]; then
            exit_error "$OPENBLASLIB not found. Use buildOpenBLAS.sh to build it"
         fi
         openblas=1
         ;;
      c) export CC="clang"
         export CXX="clang++"
         ;;
      t) case $OPTARG in
            release | native | opt | tune | debug | opt)
                build_type=$OPTARG
            ;;
            *) exit_error "Invalid build type ${OPTARG}"
            ;;
         esac
         ;;
      i) case $OPTARG in
            valgrind | valgrind2 | profile)
                inst_type=$OPTARG
            ;;
            *) exit_error "Invalid instrumentation ${OPTARG}"
            ;;
         esac
         ;;
      R) if [ $(echo $OPTARG | grep -oP "(\d\.\d\.\d)|(devel)") ]; then
            R_VERSION=$OPTARG
         else
            exit_error "mangled R version '${OPTARG}'"
         fi
         ;;
      N) R_NAME=$OPTARG
         ;;
      q) check=1
         ;;
      \?) # Invalid option 
         exit_error "Invalid option '${option}'"
         ;;
   esac
done

if [ -z "$R_NAME" ]; then
    exit_error "please provide a name (-N)"
fi
INST_DIR="${INST_DIR}/${R_NAME}"

# choose r-devel or r-base source tree
if [ "$R_VERSION" == "devel" ]; then
    R_SRC="${R_DAILY}R-devel.tar.gz"
else
    R_SRC="${R_BASE}R-$(r_major $R_VERSION)/R-${R_VERSION}.tar.gz"
fi

if [ -z "$build_type" ]; then
    if [[ "$inst_type" != "valgrind2" ]]; then
        exit_error "No build type given"
    fi
else
    if [[ "$inst_type" == "valgrind2" ]]; then
        echo "built type (-t) fixed to 'release' with valgrind2 instrumentation"
        build_type="release"
    fi
fi

# aggregate build flags
if [[ "$CC" == "clang" ]]; then
    if [[ "$inst_type" == "valgrind" || "$inst_type" == "valgrind2" ]]; then
        # valgrind can't handle dwaft5
        OPTFLAGS="-gdwarf-4"
    fi
    OPTLDFLAGS="-fopenmp=libomp"   # remove '-pthread'
fi

# optimization
if [[ "$build_type" == "debug" ]]; then
    OPTFLAGS="-O0 -fno-omit-frame-pointer ${OPTFLAGS}"
elif [[ "$build_type" == "opt" ]]; then
    OPTFLAGS="-DNDEBUG -O3 ${OPTFLAGS}"
else 
    OPTFLAGS="-DNDEBUG -O2 ${OPTFLAGS}"
fi

# tune/arch
if [[ "$build_type" == "tune" || "$build_type" == "native" || "$build_type" == "opt" ]]; then
    OPTFLAGS="${OPTFLAGS} -mtune=native"
fi
if [[ "$build_type" == "native" || "$build_type" == "opt" ]]; then
    OPTFLAGS="${OPTFLAGS} -march=native"
    OPTCONFIG="${OPTCONFIG} --with-libdeflate-compression"
fi

# instrumentation
if [[ "$inst_type" == "profile" ]]; then
    OPTCONFIG="$OPTCONFIG --enable-memory-profiling"
    OPTFLAGS="$OPTFLAGS -pg"
    OPTLDFLAGS="$OPTLDFLAGS -pg"
fi

# OpenBLAS
if [[ ! -z "$openblas" ]]; then
    if [[ $build_type == "native" || $build_type == "opt" ]]; then
         OPTCONFIG="$OPTCONFIG --with-blas=\"-L$INST_DIR/opt/lib -lopenblas-omp\"
         OPTCONFIG="$OPTCONFIG --with-lapack=\"-L$INST_DIR/opt/lib -lopenblas-omp\"
    else
        echo "OpneBlas only supported for 'native' and 'opt' builds"
        exit
    fi
fi

export CFLAGS="${CFLAGS} ${OPTFLAGS}"
export CXXFLAGS="${CXXFLAGS} ${OPTFLAGS}"
export FCFLAGS="${FCFLAGS} ${OPTFLAGS}"
export LDFLAGS="${OPTLDFLAGS}"

echo "CC = $CC"
echo "CXX = $CXX"
echo "FC = $FC"
echo "CFLAGS: $CFLAGS"
echo "CXXFLAGS: $CXXFLAGS"
echo "FCFLAGS: $FCFLAGS"
echo "LDFLAGS: $LDFLAGS"
echo "--prefix=${INST_DIR} ${CONFIG} ${OPTCONFIG}"

if [ ! -z $check ]; then
    exit
fi

# pull source tree into ./build/r-source
if [ ! -d $BUILD_DIR ]; then
    mkdir $BUILD_DIR
fi
cd $BUILD_DIR
if [ -d "./$R_NAME" ]; then
    # clobber old build
    rm -rf "./$R_NAME"
fi
wget $R_SRC -O "$R_VERSION.tar.gz"
tar -xf "$R_VERSION.tar.gz"
rm "$R_VERSION.tar.gz"

# rename build directory
mv "R-$R_VERSION" $R_NAME
cd $R_NAME

./configure --prefix=${INST_DIR} ${CONFIG} ${OPTCONFIG}
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

# symlinks
cd $SH_DIR
bash -e "${SH_DIR}/selectR.sh" ${R_NAME}

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
Rbin="$HOME/opt/bin/Rscript"
$Rbin -e "install.packages(c('BH', 'R6', 'jsonlite', 'Rcpp'), repos='${R_MIRROR}')"
$Rbin -e "install.packages(c('devtools', 'remotes', 'magrittr', 'SuppDists'), repos='${R_MIRROR}')"
$Rbin -e "install.packages(c('testit', 'microbenchmark'), repos='${R_MIRROR}')"

# add vscode support packages
# pull from github to get the newest versions
$Rbin -e "install.packages(c('httpgd'), repos='${R_MIRROR}')"
RVSCODE="\
library('remotes');\
remotes::install_github('REditorSupport/languageserver');\
remotes::install_github('ManuelHentschel/vscDebugger');\
"
$Rbin -e $RVSCODE

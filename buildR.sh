#!/bin/bash

# filename: dummy.sh
# author: @Hanno

INST_DIR="$HOME/opt"
R_VERSION="4.2.2"       # default

export CC="gcc"
export CXX="g++"
export FC="gfortran"

# based on R CMD config <X>FLAGS:
CFLAGS="-fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -g -Wall"
CXXFLAGS="-fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -g -Wall"
FCFLAGS="-fstack-protector-strong"
OPTFLAGS=""

CONFIG="LIBnn=lib --disable-nls --enable-BLAS-shlib --enable-R-shlib --enable-memory-profiling"
OPTCONFIG=""

export R_BATCHSAVE="--no-save --no-restore"

R_DAILY="https://stat.ethz.ch/R/daily/"         # daily r-devel
R_BASE="https://cran.r-project.org/src/base/"   # official release
R_MIRROR="https://cran.uni-muenster.de/"        # CRAN mirror


usage() {
cat << EOF  
Usage: $0 -R <R version> [-chti]
-h      Display help
-c      Use clang
-t      build type: debug|release|native
-i      instrumentation: valgrind
-R      R version, "devel" or full version e.g. 4.2.1, defaults to ${R_VERSION}
EOF
}


exit_error() {
    if [ -z "$1" ]; then
        usage
    else
        echo "Error: ${1}. Use $0 -h for help"
    fi
    exit 1
}


r_major () {
    echo ${1:0:1}
}


while getopts ":hct:i:R:" option; do
   case $option in
      h) usage
         exit
         ;;
      c) export CC="clang"
         export CXX="clang++"
         ;;
      t) case $OPTARG in
            release) OPTFLAGS="${OPTFLAGS} -g -O2";;
            native) OPTFLAGS="${OPTFLAGS} -g -O2 -march=native";;
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
    exit_error "No flavor given"
fi

export CFLAGS="${CFLAGS} ${OPTFLAGS}"
export CXXFLAGS="${CXXFLAGS} ${OPTFLAGS}"
export FCFLAGS="${FCFLAGS} ${OPTFLAGS}"

echo "$CC: $CFLAGS"
echo "$CXX: $CXXFLAGS"
echo "$FC: $FCFLAGS"
echo "configure: $CONFIG $OPTCONFIG"

# pull source tree into ./tmp/r-source
if [ -d ./tmp ]; then
    rm -rf ./tmp
fi
mkdir ./tmp
cd ./tmp
wget $R_SRC -O "$R_VERSION.tar.gz"
tar -xf "$R_VERSION.tar.gz"

cd "R-$R_VERSION"
./configure --prefix=$INST_DIR $CONFIG $OPTCONFIG
# make clean
make --jobs=$(nproc) 
make install

# add some packages
$INST_DIR/bin/R -e "install.packages(c('devtools', 'Rcpp'), repos='${R_MIRROR}')"

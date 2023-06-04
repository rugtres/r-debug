#!/bin/bash

# install prerequisites for compiling/running R
# assumes Debian bookworm, enforces clang-$CLANGVER gcc-12 gfortran-12
#
# Hanno 2023

cd $(dirname -- ${0})

PROFILE="$HOME/.bashrc"

GCCVER=12
CLANGVER=16

SUDO=''
if [[ $EUID -ne 0 ]]; then
    SUDO='sudo'
fi

# Build chains
$SUDO apt -y install \
    git rsync wget curl tree \
    build-essential \
    gcc-$GCCVER gfortran-$GCCVER gdb \
    lldb-$CLANGVER lld-$CLAGVER \
    libc++-$CLANGVER-dev libc++abi-$CLANGVER-dev libomp-$CLANGVER-dev \
    libllvm-$CLANGVER-ocaml-dev libllvm$CLANGVER llvm-$CLANGVER llvm-$CLANGVER-dev llvm-$CLANGVER-runtime \
    clang-$CLANGVER clang-tools-$CLANGVER libclang-common-$CLANGVER-dev libclang-$CLANGVER-dev libclang1-$CLANGVER \
    clang-format-$CLANGVER python3-clang-$CLANGVER clangd-$CLANGVER clang-tidy-$CLANGVER \
    valgrind-dbg \
    cmake

$SUDO update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-$GCCVER $GCCVER
$SUDO update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-$GCCVER $GCCVER
$SUDO update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-$GCCVER $GCCVER
$SUDO update-alternatives --install /usr/bin/clang clang /usr/bin/clang-$CLANGVER $CLANGVER
$SUDO update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-$CLANGVER $CLANGVER
$SUDO update-alternatives --install /usr/bin/lldb lldb /usr/bin/lldb-$CLANGVER $CLANGVER

$SUDO apt -y install \
    libbz2-dev liblzma-dev \
    libreadline-dev libfribidi-dev libpcre2-dev \
    libcurl4-openssl-dev libssl-dev libxml2-dev \
    libharfbuzz-dev libfreetype6-dev qpdf \
    xorg-dev pandoc libcairo-dev \
    texlive-science texlive-base texlive-fonts-extra texinfo texi2html \
    libpng-dev libtiff5-dev libjpeg-dev \
    default-jdk

# bloat by some packages in circulation in TRES
$SUDO apt -y install \
    libpq-dev libudunits2-dev libgeos-dev libgdal-dev \
    unixodbc unixodbc-dev

# copy over Rprofile
cp Rprofile.httpgd $HOME/.Rprofile

# add some stuff to $PROFILE
if [[ $( cat $PROFILE | grep -c "^# prepR.sh") -eq "0" ]]; then
    echo >> $PROFILE
    echo '# prepR.sh' >> $PROFILE
    echo 'export LC_ALL=en_US.UTF-8' >> $PROFILE
    echo 'export LANG=en_US.UTF-8' >> $PROFILE
    echo 'PATH=~/opt/bin:$PATH' >> $PROFILE
fi

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
$SUDO dpkg-reconfigure locales

# create root system in ~/opt
mkdir -p $HOME/opt/bin
mkdir -p $HOME/opt/lib
mkdir -p $HOME/opt/share

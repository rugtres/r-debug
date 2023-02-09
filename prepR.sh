#!/bin/bash

# install prerequisites for compiling/running R
# assumes Debian bookworm, enforces clang-15 gcc-12 gfortran-12
#
# Hanno 2023

PROFILE="$HOME/.bashrc"

GCCVER=-12
CLANGVER=-15

SUDO=''
if [[ $EUID -ne 0 ]]; then
    SUDO='sudo'
fi

# Build chains
$SUDO apt -y install \
    git rsync wget curl \
    build-essential \
    gcc$GCCVER gfortran$GCCVER gdb \
    clang$CLANGVER lldb$CLANGVER libomp$CLANGVER-dev \
    valgrind-dbg

$SUDO update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc$GCCVER 12
$SUDO update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++$GCCVER 12
$SUDO update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran$GCCVER 12
$SUDO update-alternatives --install /usr/bin/clang clang /usr/bin/clang$CLANGVER 15
$SUDO update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++$CLANGVER 15
$SUDO update-alternatives --install /usr/bin/lldb lldb /usr/bin/lldb$CLANGVER 15

$SUDO apt -y install \
    libbz2-dev liblzma-dev \
    libreadline-dev libfribidi-dev libpcre2-dev \
    libcurl3-openssl-dev libssl-dev \
    libharfbuzz-dev libfreetype6-dev qpdf \
    xorg-dev pandoc libcairo-dev \
    texlive-science texlive-base texlive-fonts-extra texinfo texi2html \
    libpng-dev libtiff5-dev libjpeg-dev \
    default-jdk 


# add some stuff to $PROFILE
if [[ $( cat $PROFILE | grep -c "^# prepR.sh") -eq "0" ]]; then
    echo >> $PROFILE
    echo '# prepR.sh' >> $PROFILE
    echo 'export LC_ALL=en_US.UTF-8' >> $PROFILE
    echo 'export LANG=en_US.UTF-8' >> $PROFILE
    echo '. $HOME/.bashrc.r-debug' >> $PROFILE 
    echo 'PATH=$PATH:~/opt/bin' > $HOME/.bashrc.r_debug
fi

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
$SUDO dpkg-reconfigure locales

## set links in ~/.local/bin
#if [ ! -d "$HOME/.local/bin" ] ; then
#    mkdir "$HOME/.local/bin"
#fi
#ln -s ~/R-devel/bin/R ~/.local/bin/R
#ln -s ~/R-devel/bin/Rscript ~/.local/bin/Rscript

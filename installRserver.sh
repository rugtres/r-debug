#!/bin/bash

# Installs rserver
# Hanno 2023

set -e

if [ ! -d ./tmp ]; then
    mkdir ./tmp
fi
cd ./tmp

# from https://posit.co/download/rstudio-server/
sudo apt-get install gdebi-core
wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-2022.12.0-353-amd64.deb
sudo gdebi rstudio-server-2022.12.0-353-amd64.deb

# better use our own R install
echo "rsession-which-r=$HOME/opt/bin/R" | sudo tee -a /etc/rstudio/rserver.conf

#!/bin/bash

# Installs rserver
# Hanno 2023

set -e
cd $(dirname -- ${0})


if [ ! -d ./tmp ]; then
    mkdir ./tmp
fi
cd ./tmp

# from https://posit.co/download/rstudio-server/
sudo apt-get install gdebi-core
wget https://download2.rstudio.org/server/jammy/amd64/rstudio-server-2023.12.1-402-amd64.deb
sudo gdebi rstudio-server-2023.12.1-402-amd64.deb

# better use our own R install
echo "rsession-which-r=$HOME/opt/bin/R" | sudo tee -a /etc/rstudio/rserver.conf

#/bin/bash

# Installs Intel's OneAPI
# Hanno 2023

wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | gpg --dearmor | sudo tee /usr/share/keyrings/oneapi-archive-keyring.gpg > dev/null
echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list

sudo apt update
sudo apt install libnss3-dev
sudo apt install libatk1.0-0
sudo apt install libatk-bridge2.0-0
sudo apt install libgtk-3-dev
sudo apt install intel-basekit

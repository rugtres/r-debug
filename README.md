# Debian 12 (bookworm) WSL2

```powershell
# powershell
wsl --install -d Debian
```
```bash
# bash
sudo nano /etc/atp/sources.list
# replace 'bullseye' with 'bookworm':
- deb http://deb.debian.org/debian bulleye main
- deb http://deb.debian.org/debian bulleye-updates main
- deb http://security.debian.org/debian-security bulleye-security main
- deb http://ftp.debian.org/debian bulleye-backports main

+ deb http://deb.debian.org/debian bookworm main
+ deb http://deb.debian.org/debian bookworm-updates main
+ deb http://security.debian.org/debian-security bookworm-security main
+ deb http://ftp.debian.org/debian bookworm-backports main

sudo apt update
sudo apt upgrade
sudo apt autoremove

# Fix Linux user for WSL export/import
sudo bash -c 'echo -e "[user]\ndefault=$USER" >> /etc/wsl.conf'
exit
```

## Prep
```bash
# bash
sudo apt -y install git wget curl
git clone git@github.com:rugtres/r-debug.git
cd r-debug
chmod +x *.sh
./prepR.sh
exit
```

## Make this the 'build' distro for R
Time to set up some other stuff like ssh...
```powershell
# powershell
wsl --terminate Debian
# export as a template and `rename`...
mkdir $HOME\wsl-exports
mkdir $HOME\wsl-rootfs
wsl --export Debian $HOME\wsl-exports\Rbuild.tar
wsl --unregister Debian
```

## Create a bunch of R distros
### Rdevel
```powershell
# powershell
wsl --import Rdevel $HOME\wsl-images\Rdevel $HOME\wsl-exports\Rbuild.tar
```
```bash
# bash
cd r-debug
./buildR.sh -R devel -t release
```
### Rrelease
```powershell
# powershell
wsl --import Rrelease $HOME\wsl-images\Rrelease $HOME\wsl-exports\Rbuild.tar
```
```bash
# bash
cd r-debug
./buildR.sh -R 4.2.2 -t release
```
### Rdebug
```powershell
# powershell
wsl --import Rdebug $HOME\wsl-images\Rdebug $HOME\wsl-exports\Rbuild.tar
```
```bash
# bash
cd r-debug
./buildR.sh -R 4.2.2 -t debug
```
### Rvalgrind
```powershell
# powershell
wsl --import Rval $HOME\wsl-images\Rval $HOME\wsl-exports\Rbuild.tar
```
```bash
# bash
cd r-debug
./buildR.sh -R 4.2.2 -t debug -i valgrind
```
### ...




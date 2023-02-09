# Debian 12 (bookworm) WSL2

```powershell
# powershell
wsl --install -d Debian
```
```bash
# bash
exit
```
```powershell
# powershell
wsl -d Debian
```
```bash
# bash
# Fix Linux user for WSL export/import
sudo bash -c 'echo -e "[user]\ndefault=$USER" >> /etc/wsl.conf'

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
```

## Prep
```bash
# bash
sudo apt -y install git wget curl
git clone https://github.com/rugtres/r-debug.git
cd r-debug
chmod +x *.sh
./prepR.sh

# Time to set up some other stuff like ssh...
exit
```

# Make this the 'build' distro for R
```powershell
# powershell
wsl --terminate Debian
# export as a template and `rename`...
mkdir $HOME\wsl-exports
mkdir $HOME\wsl-rootfs
wsl --export Debian $HOME\wsl-exports\Rbuild.tar
wsl --unregister Debian
```

# Create a distro with multiple R builds
```powershell
# powershell
wsl --import Rmulti $HOME\wsl-images\Rmulti $HOME\wsl-exports\Rbuild.tar
wsl -d Rmulti
```
```bash
# bash
cd r-debug
./buildR.sh -N Rrelease -t release
./buildR.sh -N Rdebug -t debug
./buildR.sh -N Rdevel -R devel -t release
./buildR.sh -N Rval -t debug -i valgrind
./buildOpenBLAS.sh
./buildR.sh -N Rnative -R devel -t native -o
# ...
# clean up
rm -rf ./tmp
``` 
## Select R version

```bash
# check what's there
ls ~/.opt
> bin  include  lib  Rdebug  Rnative  Rrelease  Rval  share
# check current
ls ~/.opt/bin -al
> ... R -> /home/hanno/opt/Rnative/bin/R
> ... Rscript -> /home/hanno/opt/Rnative/bin/Rscript

# switch
./selectR.sh Rdebug
# double-check
ls ~/.opt/bin -al
> total 8
> ... R -> /home/hanno/opt/Rdebug/bin/R
> ... Rscript -> /home/hanno/opt/Rdebug/bin/Rscript
```
A similar symlink-jazz is applied to `~\.R\Makevars`.

### Is 'Rnative' worth it?
```bash
./selectR.sh Rnative
Rscript R-benchmark-25.R
```
```
   R Benchmark 2.5
   ===============
Number of times each test is run__________________________:  3

   I. Matrix calculation
   ---------------------
Creation, transp., deformation of a 2500x2500 matrix (sec):  0.382666666666667
2400x2400 normal distributed random matrix ^1000____ (sec):  0.147666666666667
Sorting of 7,000,000 random values__________________ (sec):  0.500666666666667
2800x2800 cross-product matrix (b = a' * a)_________ (sec):  0.0869999999999997
Linear regr. over a 3000x3000 matrix (c = a \ b')___ (sec):  0.0943333333333332
                      --------------------------------------------
                 Trimmed geom. mean (2 extremes eliminated):  0.174685193471483

   II. Matrix functions
   --------------------
FFT over 2,400,000 random values____________________ (sec):  0.162333333333333
Eigenvalues of a 640x640 random matrix______________ (sec):  0.36
Determinant of a 2500x2500 random matrix____________ (sec):  0.102666666666667
Cholesky decomposition of a 3000x3000 matrix________ (sec):  0.0923333333333337
Inverse of a 1600x1600 random matrix________________ (sec):  0.112666666666667
                      --------------------------------------------
                Trimmed geom. mean (2 extremes eliminated):  0.123370371150351

   III. Programmation
   ------------------
3,500,000 Fibonacci numbers calculation (vector calc)(sec):  0.145
Creation of a 3000x3000 Hilbert matrix (matrix calc) (sec):  0.117
Grand common divisors of 400,000 pairs (recursion)__ (sec):  0.127333333333335
Creation of a 500x500 Toeplitz matrix (loops)_______ (sec):  0.0280000000000011
Escoufier's method on a 45x45 matrix (mixed)________ (sec):  0.172999999999998
                      --------------------------------------------
                Trimmed geom. mean (2 extremes eliminated):  0.129270270444724


Total time for all 15 tests_________________________ (sec):  2.63266666666667
Overall mean (sum of I, II and III trimmed means/3)_ (sec):  0.140708999368685
                      --- End of test ---
```

```bash
./selectR.sh Rrelease
Rscript R-benchmark-25.R
```
```
   R Benchmark 2.5
   ===============
Number of times each test is run__________________________:  3

   I. Matrix calculation
   ---------------------
Creation, transp., deformation of a 2500x2500 matrix (sec):  0.424666666666667
2400x2400 normal distributed random matrix ^1000____ (sec):  0.152
Sorting of 7,000,000 random values__________________ (sec):  0.544333333333333
2800x2800 cross-product matrix (b = a' * a)_________ (sec):  9.84133333333333
Linear regr. over a 3000x3000 matrix (c = a \ b')___ (sec):  4.73733333333333
                      --------------------------------------------
                 Trimmed geom. mean (2 extremes eliminated):  1.0307397287917

   II. Matrix functions
   --------------------
FFT over 2,400,000 random values____________________ (sec):  0.158666666666666
Eigenvalues of a 640x640 random matrix______________ (sec):  0.569666666666665
Determinant of a 2500x2500 random matrix____________ (sec):  2.475
Cholesky decomposition of a 3000x3000 matrix________ (sec):  4.04166666666666
Inverse of a 1600x1600 random matrix________________ (sec):  1.886
                      --------------------------------------------
                Trimmed geom. mean (2 extremes eliminated):  1.38541291932077

   III. Programmation
   ------------------
3,500,000 Fibonacci numbers calculation (vector calc)(sec):  0.130999999999995
Creation of a 3000x3000 Hilbert matrix (matrix calc) (sec):  0.12466666666667
Grand common divisors of 400,000 pairs (recursion)__ (sec):  0.143666666666661
Creation of a 500x500 Toeplitz matrix (loops)_______ (sec):  0.027000000000001
Escoufier's method on a 45x45 matrix (mixed)________ (sec):  0.215000000000003
                      --------------------------------------------
                Trimmed geom. mean (2 extremes eliminated):  0.132879877638308


Total time for all 15 tests_________________________ (sec):  25.472
Overall mean (sum of I, II and III trimmed means/3)_ (sec):  0.574639959543244
                      --- End of test ---
```

# rstudio-server

## Install w/o R - we have that ;)
```bash
cd r-debug
./installRserver.sh
```
## Start rstudio-rserver
First, start rstudio-server: `sudo rstudio-server start`<br>
Next, open your browser and navigate to: `127.0.0.1:8787`<br>
Enter your Linux-credentials...<br>

## Stop/restart/kill
To stop rstudio-server use: `sudo rstudio-server stop`<br>
Went south? Use: `sudo rstudio-server restart`<br>
Reached Antarctica? Use: `sudo rstudio-server kill`<br>


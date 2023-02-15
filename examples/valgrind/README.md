# Valgrind

Valgrind can help you tracking down *some* memory errors.
Run the buggy file [segfault.cpp](segfault.cpp) with:
```
R -e "idx=100000; Rcpp::sourceCpp('segfault.cpp')"
```
And again with:
```
R -d valgrind -e "idx=100000; Rcpp::sourceCpp('segfault.cpp')"
```
Note: we don't need to use `Rval` here because `valgrind` will pick up this stupid
C/C++ error without instrumentation. `Rval` is meant for detecting memory errors
within R.<br>

Try the same with:
```
R -e "idx=100; Rcpp::sourceCpp('segfault.cpp')"
```
That's as bad as before but this time, even valgrind, doesn't complain :(
```
R -d valgrind -e "idx=100; Rcpp::sourceCpp('segfault.cpp')"
```
Anyhow, `Rval` spits out a ton of (mostly false) positives:
```
../../selectR.sh Rval
R -d valgrind -e "idx=100; Rcpp::sourceCpp('segfault.cpp')"
```
Let's say `valgrind` has it's use cases...

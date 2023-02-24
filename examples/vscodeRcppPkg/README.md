# vscodeRcppPkg

Skeleton was created in R along:

```txt
library(Rcpp)
library(usethis)
Rcpp.package.skeleton("vscodeRcppPkg", attributes=TRUE)
usethis::use_build_ignore(c("README.md", ".vscode"))
usethis::use_testthat()
```

We want to debug our C/C++ code in [./src/rcpp_src.cpp](./src/rcpp_src.cpp) during `devtools::test()`.<br>
All the magic happens, as usual, inside `.vscode`:<br>

.vscode/<br>
├── [c_cpp_properties.json](./.vscode/c_cpp_properties.json)<br>
├── [genenv.R](./.vscode/genenv.R)<br>
├── [launch.json](./.vscode/launch.json)<br>
└── [tasks.json](./.vscode/tasks.json)<br>

## Debug

On the debug panel (`Ctrl+Shift+D)`, you can find "`Launch devtools::test()`".<br>
Set breakpoints (`F9`) in `rcpp_src.cpp`, click the `|>` button -- enjoy debugging!

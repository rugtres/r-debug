library(vscodeRcppPkg)

x <- as.double(1:1000000)
for (i in 1:1000) {
    sum <- rcpp_sum(x)
}

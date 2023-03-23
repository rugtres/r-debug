library(vscodeRcppPkg)

x <- 1:1000000
for (i in 1:10000) {
    sum <- rcpp_sum(x)
}

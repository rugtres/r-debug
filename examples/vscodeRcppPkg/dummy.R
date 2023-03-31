library(vscodeRcppPkg)

foo <- function(fun, x) {
    s <- 0
    for (i in 1:10000) {
        s <- s + fun(x)
    }
    return(s)
}

rcpp_break(0)

x <- as.double(1:1000000)
s <- foo(mean, x)

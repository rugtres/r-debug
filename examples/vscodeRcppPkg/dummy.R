library(vscodeRcppPkg)


foo <- function(x, k = max(d)) {
    d <- dim(x)
    return(k + 1)
}

x <- matrix(1:10, nrow = 5)
print(foo(x))


bar <- function(expr) {
#    (expr)
    return()
}

fu <- function(expr) {
    bar(expr)
    return()
}

y <- 1:10
fu(y)

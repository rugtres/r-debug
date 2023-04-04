# kinda interesting source files:
#
# ~/opt/bin/Rsrc/main/summary.c (541)
# ~/opt/bin/Rsrc/main/altclasses.c (500)

library(vscodeRcppPkg)

foo <- function(fun, x) {
    s <- 0
    for (i in 1:1000) {
        rcpp_break(0)
        s <- s + fun(x)
    }
    return(s)
}
#x <- seq(from = 1, to = 100000)
#s <- foo(mean, x)
#print(s)

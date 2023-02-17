# Use 'CTRL+SHIFT+S' to source this file (or click the run button)

dup <- function(val) {
    return(2 * val)
}

# Use 'CTRL+Enter' to execute a selected code block
x <- c(1, 2, 3, 4)
y <- 2^x

z <- x + y
w <- dup(z)
plot(x, w)

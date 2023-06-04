library(RcppParallelNumThreads)
library(microbenchmark)

x <- seq(from = 0.0, to = 1.0, by = 0.000000001)
fun <- tbb_global_control_parallelVectorSum

bench <- function(numThreads = 'auto') {
    # iff numThreads != `auto`:
    #   env. variable RCPP_RCPP_PARALLEL_NUM_THREADS is set to 'numThreads'
    # iff numThreads == `auto`:
    #   deletes(!) the environment variable RCPP_RCPP_PARALLEL_NUM_THREADS
    #
    # Either way, it *doesn't* affect TBB!
    RcppParallel::setThreadOptions(numThreads)
    fun(x)
}

control <- list("inorder", 2)
names(control) <- c("order", "warmup")
rr <- microbenchmark::microbenchmark("1 thread" = bench(1),
                                     "2 threads" = bench(2),
                                     "4 threads" = bench(4),
                                     "8 threads" = bench(8),
                                     "16 threads" = bench(16),
                                     "auto" = bench(),
                                     control = control,
                                     times = 10)
print(rr)

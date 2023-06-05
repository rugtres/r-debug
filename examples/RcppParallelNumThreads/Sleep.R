library(RcppParallelNumThreads)
library(microbenchmark)

bench <- function(numThreads, N, ms) {
    # iff numThreads != `auto`:
    #   env. variable RCPP_RCPP_PARALLEL_NUM_THREADS is set to 'numThreads'
    # iff numThreads == `auto`:
    #   deletes(!) the environment variable RCPP_RCPP_PARALLEL_NUM_THREADS
    #
    # Either way, it *doesn't* affect TBB!
    RcppParallel::setThreadOptions(numThreads)
    tbb_parallel_sleep(N, ms)
}

control <- list("inorder", 2)
names(control) <- c("order", "warmup")
rr <- microbenchmark::microbenchmark("1 thread" = bench(1, 10, 100),
                                     "2 threads" = bench(2, 10, 100),
                                     "4 threads" = bench(4, 10, 100),
                                     "8 threads" = bench(8, 10, 100),
                                     "16 threads" = bench(16, 10, 100),
                                     "auto" = bench('auto', 10, 100),
                                     control = control,
                                     times = 10)
print(rr)

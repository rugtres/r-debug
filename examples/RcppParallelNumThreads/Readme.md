# RcppParallel num_threads

Pin versions in **DESCRIPTION**. Older ones might not support the newer oneTBB

```
Imports: Rcpp (>= 1.0.10), RcppParallel (>= 5.1.7)
```

## RcppParallel::SetThreadOptions

Apparently *the* function to control the max. number of threads within RcppParallel:

`setThreadOptions(numThreads = "auto", stackSize = "auto")`

Well, it *does* control `numThreads` for RcppParallel's native functionality.<br>
However, it has **no influence on TBB**!

`setThreadOptions` sets the environment variable `RCPP_PARALLEL_NUM_THREADS` to `numThreads`
if the argument is not `"auto"`.<br>
If `numThreads = "auto"`, the environment variable is *removed*!<br>
Again, no effect on **TBB**!

I think that users of RcppParallel expect the `setThreadOptions` function to apply
to everything in RcppParallel, including TBB (I did). Instead of passing down a 'num_thread'
argument, we should check `RCPP_PARALLEL_NUM_THREADS` in our TBB code:

```c++
#include <Rcpp.h>
#include <RcppParallel.h>
#include <cstdlib>          // std::getenv

// probably the cleanest way to retrieve RcppParallel's concurrency setting
size_t get_rcpp_num_threads() {
  auto* nt_env = std::getenv("RCPP_PARALLEL_NUM_THREADS");
  return (nullptr == nt_env) 
    ? tbb::task_arena::automatic      // -1
    : static_cast<size_t>(std::atoi(nt_env));
}
```


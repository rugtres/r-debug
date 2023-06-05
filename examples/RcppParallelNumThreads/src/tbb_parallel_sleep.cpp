/**
 *
 * This file contains example code showcasing how RcppParallel
 * can be used. In this file, we define and export a function called
 * 'parallelVectorSum()', which computes the sum of a numeric vector
 * in parallel.
 *
 * Please see https://rcppcore.github.io/RcppParallel/ for more
 * details on how to use RcppParallel in an R package, and the
 * Rcpp gallery at http://gallery.rcpp.org/ for more examples.
 *
 */

// [[Rcpp::depends(RcppParallel)]]
#include <Rcpp.h>
#include <RcppParallel.h>
#include <cstdlib>
#include <functional>
#include <thread>

using namespace Rcpp;
using namespace RcppParallel;

namespace {

  // probably the cleanest way to retrieve RcppParallel's concurrency setting
  size_t get_rcpp_num_threads() {
    auto* nt_env = std::getenv("RCPP_PARALLEL_NUM_THREADS");
    return (nullptr == nt_env) 
      ? tbb::task_arena::automatic      // -1
      : static_cast<size_t>(std::atoi(nt_env));
  }

}


// [[Rcpp::export]]
void tbb_parallel_sleep(int N, int ms) {
    tbb::global_control _{tbb::global_control::max_allowed_parallelism, get_rcpp_num_threads()};
    tbb::parallel_for(tbb::blocked_range<int>(0,N), [=](auto r) {
      for (auto it = r.begin(); it != r.end(); ++it) {
        std::this_thread::sleep_for(std::chrono::milliseconds(ms));
      }
    });
}

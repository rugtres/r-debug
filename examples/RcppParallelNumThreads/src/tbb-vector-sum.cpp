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


// probably the cleanest way to retrieve RcppParallel's concurrency setting
size_t get_rcpp_num_threads() {
  auto* nt_env = std::getenv("RCPP_PARALLEL_NUM_THREADS");
  return (nullptr == nt_env) 
    ? tbb::task_arena::automatic      // -1
    : static_cast<size_t>(std::atoi(nt_env));
}


// [[Rcpp::export]]
double tbb_arena_parallelVectorSum(NumericVector x) {
  tbb::task_arena arena(get_rcpp_num_threads());
  auto sum = 0.0;
  arena.execute([&]() {
    sum = tbb::parallel_reduce(tbb::blocked_range<int>(0,x.size()), 0.0,
      [&](tbb::blocked_range<int> r, double running_total) {
        for (int i=r.begin(); i<r.end(); ++i) {
          running_total += x[i];
        }
        return running_total;
      }, std::plus<double>() 
    );
  });
  return sum;
}


// [[Rcpp::export]]
double tbb_global_control_parallelVectorSum(NumericVector x) {
  tbb::global_control _{tbb::global_control::max_allowed_parallelism, get_rcpp_num_threads()};
  auto sum = tbb::parallel_reduce(tbb::blocked_range<int>(0,x.size()), 0.0,
    [&](tbb::blocked_range<int> r, double running_total) {
      for (auto i = r.begin(); i < r.end(); ++i) {
        running_total += x[i];
      }
      return running_total;
    }, std::plus<double>()
  );
  return sum;
}

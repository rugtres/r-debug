#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
int ouch(int idx) {
  int x[10] = {1,2,3,4,5 };
  return x[idx];
}

/***R
ouch(idx)
*/
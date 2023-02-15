#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
int ouch(int idx) {
  int x[10] = {};
  return x[idx];
}

/*** R
ouch(idx)
*/

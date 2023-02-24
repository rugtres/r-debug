// [[Rcpp::plugins(cpp17)]]

#include <Rcpp.h>
#include <vector>
using namespace Rcpp;


//' Simple sum
//' @param x a numeric vector
//' @export
// [[Rcpp::export]]
double rcpp_sum(NumericVector x) {
  double sum = 0.0;
  for (auto val : x) {
    sum += val;
  }
  return sum;
}

//' Concats two vectors
//' @param a first numeric vector
//' @param b second numeric vector
//' @export
// [[Rcpp::export]]
std::vector<double> rcpp_concat(const std::vector<double>& a, const std::vector<double>& b) {
  auto res = a;
  res.insert(res.end(), b.cbegin(), b.cend());
  return res;
}


//' Returns x[idx]
//' @param x a numeric vector
//' @param idx the index
//' @export
// [[Rcpp::export]]
double rcpp_idx(const std::vector<double>& x, int idx) {
  return x[idx];
}

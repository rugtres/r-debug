// [[Rcpp::plugins(cpp17)]]

#include <Rcpp.h>
#include <vector>
#include <numeric>
using namespace Rcpp;


//' Break me
//' @param msg
//' @export
// [[Rcpp::export]]
void rcpp_break(int msg) {
  static int count = 0;
  ++count;
}


// [[Rcpp::export]]
void rcpp_any(SEXP expr) {
  return;
}


//' Simple sum
//' @param x a numeric vector
//' @export
// [[Rcpp::export]]
double rcpp_sum(NumericVector x) {
  double sum = 0.0;
  for (auto val : x) {
    sum += val + 1.0;
  }
  return sum;
}

//' Simple mean
//' @param x a numeric vector
//' @export
// [[Rcpp::export]]
double rcpp_mean(NumericVector x) {
  auto sum = std::accumulate(x.begin(), x.end(), 0.0);
  return sum / x.size();
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

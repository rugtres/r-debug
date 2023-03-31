// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

#ifdef RCPP_USE_GLOBAL_ROSTREAM
Rcpp::Rostream<true>&  Rcpp::Rcout = Rcpp::Rcpp_cout_get();
Rcpp::Rostream<false>& Rcpp::Rcerr = Rcpp::Rcpp_cerr_get();
#endif

// rcpp_break
void rcpp_break(int msg);
RcppExport SEXP _vscodeRcppPkg_rcpp_break(SEXP msgSEXP) {
BEGIN_RCPP
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< int >::type msg(msgSEXP);
    rcpp_break(msg);
    return R_NilValue;
END_RCPP
}
// rcpp_sum
double rcpp_sum(NumericVector x);
RcppExport SEXP _vscodeRcppPkg_rcpp_sum(SEXP xSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< NumericVector >::type x(xSEXP);
    rcpp_result_gen = Rcpp::wrap(rcpp_sum(x));
    return rcpp_result_gen;
END_RCPP
}
// rcpp_mean
double rcpp_mean(NumericVector x);
RcppExport SEXP _vscodeRcppPkg_rcpp_mean(SEXP xSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< NumericVector >::type x(xSEXP);
    rcpp_result_gen = Rcpp::wrap(rcpp_mean(x));
    return rcpp_result_gen;
END_RCPP
}
// rcpp_concat
std::vector<double> rcpp_concat(const std::vector<double>& a, const std::vector<double>& b);
RcppExport SEXP _vscodeRcppPkg_rcpp_concat(SEXP aSEXP, SEXP bSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const std::vector<double>& >::type a(aSEXP);
    Rcpp::traits::input_parameter< const std::vector<double>& >::type b(bSEXP);
    rcpp_result_gen = Rcpp::wrap(rcpp_concat(a, b));
    return rcpp_result_gen;
END_RCPP
}
// rcpp_idx
double rcpp_idx(const std::vector<double>& x, int idx);
RcppExport SEXP _vscodeRcppPkg_rcpp_idx(SEXP xSEXP, SEXP idxSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const std::vector<double>& >::type x(xSEXP);
    Rcpp::traits::input_parameter< int >::type idx(idxSEXP);
    rcpp_result_gen = Rcpp::wrap(rcpp_idx(x, idx));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_vscodeRcppPkg_rcpp_break", (DL_FUNC) &_vscodeRcppPkg_rcpp_break, 1},
    {"_vscodeRcppPkg_rcpp_sum", (DL_FUNC) &_vscodeRcppPkg_rcpp_sum, 1},
    {"_vscodeRcppPkg_rcpp_mean", (DL_FUNC) &_vscodeRcppPkg_rcpp_mean, 1},
    {"_vscodeRcppPkg_rcpp_concat", (DL_FUNC) &_vscodeRcppPkg_rcpp_concat, 2},
    {"_vscodeRcppPkg_rcpp_idx", (DL_FUNC) &_vscodeRcppPkg_rcpp_idx, 2},
    {NULL, NULL, 0}
};

RcppExport void R_init_vscodeRcppPkg(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}

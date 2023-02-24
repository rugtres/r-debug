test_that("sum works", {
  expect_equal(rcpp_sum(numeric()), 0)
  expect_equal(rcpp_sum(c(1, 2, 3)), 6)
})

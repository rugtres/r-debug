test_that("concat works", {
  expect_equal(rcpp_concat(c(1), c(2, 3)), c(1, 2, 3))
})

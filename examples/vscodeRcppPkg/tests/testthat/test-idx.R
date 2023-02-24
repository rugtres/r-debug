test_that("idx works", {
  expect_equal(rcpp_idx(c(1, 2, 3), 2), 3)
})

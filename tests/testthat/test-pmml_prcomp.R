context("pmml_prcomp")

library(magrittr)
library(XML)
library(purrr)

my_iris <- iris[, -5]
index <- 1
pca_list <- map2(.x = c(FALSE, FALSE, TRUE, TRUE),
                 .y = c(FALSE, TRUE, FALSE, TRUE),
                 ~ prcomp(my_iris, center = .x, scale. = .y))
pmml_list <- map(pca_list, ~ pmml_prcomp(.x, index) %>%
                   saveXML(tempfile()) %>%
                   xmlParse() %>%
                   xmlRoot())


test_that("Coefficients are inserted correctly to PMML", {
  pca_coefficients <- map(pca_list, ~ .x[["rotation"]][, index] %>%
                            as.vector)
  pmml_coefficients <- map(pmml_list, ~ xpathSApply(.x, "//ns:NumericPredictor/@coefficient",
                                                    namespaces = c(ns = XML::getDefaultNamespace(.x))) %>%
                             as.numeric)
  map2(pca_coefficients, pmml_coefficients, expect_equal)
})


test_that("Center information is inserted correctly to PMML", {

  pca_centers <- map(pca_list, ~ .x[["center"]] %>% as.vector)
  # Taking into account that not all prcomp objects contain centering information
  pca_centers <- map_if(pca_centers, is.logical, ~ vector(mode = "numeric", length = 0))
  pmml_centers <-  purrr::map(pmml_list, ~ xpathSApply(.x, "//ns:Apply[@function='-']/ns:Constant",
                                    xmlValue,
                                    namespaces = c(ns = getDefaultNamespace(.x))) %>%
    as.numeric)

  map2(pca_centers, pmml_centers, expect_equal)
})


test_that("Scaling information is inserted correctly to PMML", {

  pca_scales <- map(pca_list, ~ .x[["scale"]] %>% as.vector)
  # Taking into account that not all prcomp objects contain scaling information
  pca_scales <- map_if(pca_scales, is.logical, ~ vector(mode = "numeric", length = 0))
  pmml_scales <-  map(pmml_list, ~ xpathSApply(.x, "//ns:Apply[@function='/']/ns:Constant",
                                                            xmlValue,
                                                            namespaces = c(ns = getDefaultNamespace(.x))) %>%
                                as.numeric)

  map2(pca_scales, pmml_scales, expect_equal)
})


test_that("Error handling works", {
  pca <- prcomp(my_iris)
  expect_error(pmml_prcomp(pca, 5), "Please specify a valid eigenvector index")
})


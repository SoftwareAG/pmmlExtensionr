context("pmml_prcomp")

library(magrittr)

my_iris <- iris[, -5]

convert_to_character <- function(xml_doc, index) {
  result <- as(xml_doc[[index]], "character") %>%
    gsub("(\r\n)+|\r+|\n+", "", .) %>%
    gsub(">[ \t]+<", "><", .)
  result
}


test_that("creates PMML correctly for false/false combination", {
  #doc <- XML::xmlParse("./tests/testthat/FF_pca.xml") %>%
  doc <- XML::xmlParse("FF_pca.xml") %>%
    XML::xmlRoot()
  pmml <- prcomp(my_iris, center = FALSE, scale. = FALSE) %>%
    pmml_prcomp(1, model.name = "iris_pca1_FF") %>%
    XML::saveXML(tempfile()) %>%
    XML::xmlParse() %>%
    XML::xmlRoot()

  l <- list(doc, pmml)

  data_dictionary_sections <- purrr::map_chr(l, convert_to_character, 2)
  regression_model_sections <- purrr::map_chr(l, convert_to_character, 3)

  expect_equal(data_dictionary_sections[1], data_dictionary_sections[2])
  expect_equal(regression_model_sections[1], regression_model_sections[2])
})

test_that("Error handling works", {
  pca <- prcomp(my_iris)
  expect_error(pmml_prcomp(pca, 5), "Please specify a valid eigenvector index")
})


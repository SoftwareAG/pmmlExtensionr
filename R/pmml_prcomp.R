#' Generate PMML for prcomp objects
#'
#' Extract one principal component from a prcomp object together with the
#' centering and scaling information and generate the PMML representation.
#'
#' In general, each principal component represents a linear combination of the
#' original input values. Therefore, the information of a single principal
#' component can be expressed as a linear function and as such be represented as
#' a linear model in PMML. \code{pmml_prcomp()} extracts one eigenvector
#' from a prcomp object together with the centering and scaling information if
#' they are present. At first, it leverages \code{FunctionXform()} from
#' \pkg{pmmlTransformations} to add the centering and scaling information to an
#' empty WrapData object. Even though this step is a kind of dirty hack, it is the
#' only option to capture the centering and scaling as pre-processing steps in
#' the PMML later. Next, a "minimal", artifical lm object is created based on
#' the coefficients of the selected principal component. "minimal" in the way
#' that all information is present which \code{pmml.lm()} from \pkg{pmml} needs
#' to create a valid PMML. In a final step the pre-processing steps and
#' the "minimal" lm object are passed to \code{pmml.lm()} to create the PMML.
#'
#' @param model A prcomp object.
#' @param j Index of the eigenvector for which the PMML will be created.
#'  Per default, the PMML will be constructed based on the eigenvector of the
#'  first principal component.
#' @param ... Further arguments passed to \code{pmml.lm()} which make sense in
#'  the given context
#'
#' @return An object of class XMLNode which is of type PMML.
#' @export
#' @examples
#' iris <- iris[, -5]
#' pc_iris <- prcomp(iris, center = FALSE, scale. = FALSE)
#' pmml_prcomp(pc_iris)
#'
#' pc_iris <- prcomp(iris, center = TRUE, scale. = TRUE)
#' pmml_prcomp(pc_iris, 2)
pmml_prcomp <- function(model, j = 1, ...) {
  if(class(model) != "prcomp")
    stop("Please provide a prcomp object")

  if (j > ncol(model$rotation))
    stop("Please specify a valid eigenvector index")

  empty_box = NULL
  field_names <- row.names(model$rotation)

  if (typeof(model$center) != "logical" || typeof(model$scale) != "logical") {
    field_names <- paste0(field_names, "_transformed")
    empty_box <- preprocess_prcomp(model$rotation[, j], model$center,
                                   model$scale, j)
  }

  pc_coef <- c("(Intercept)" = 0, model$rotation[, j])

  names(pc_coef)[2:length(pc_coef)] <- field_names
  dataClasses <- rep("numeric", length(pc_coef))
  names(dataClasses) <- names(pc_coef)
  names(dataClasses)[1] <- paste0("PC", j)

  fit <- list(coefficients = pc_coef, call = call("lm"), terms = NULL)
  attributes(fit$terms) <- list(dataClasses = dataClasses)
  class(fit) <- "lm"

  pmml <- pmml::pmml.lm(fit, transforms = empty_box,
                        ...)
  pmml
}


#' Create preprocessing steps for prcomp objects
#'
#' @param eigenvector	Eigenvector containing variable names
#' @param center The centering used, or FALSE
#' @param scale The scaling used, or FALSE
#' @param j Selected eigenvector index
#'
#' @return A WrapData object containing the preprocessing steps
preprocess_prcomp <- function(eigenvector, center, scale, j) {
  empty_df<- data.frame(matrix(data = rep(0, length(eigenvector) + 1),
                               nrow = 1, ncol = length(eigenvector) + 1))
  names(empty_df) <- c(names(eigenvector), paste0("PC", j))
  empty_box <- pmmlTransformations::WrapData(empty_df)

  origFieldName <-  names(eigenvector)
  newFieldName <- paste0(origFieldName, "_transformed")


  if (typeof(center) != "logical" && typeof(scale) == "logical")
    formulaText <- quote(paste0(origFieldName[i], "-", center[i]))
  else if (typeof(center) == "logical" && typeof(scale) != "logical")
    formulaText <- quote(paste0(origFieldName[i], "/", scale[i]))
  else
    formulaText <- quote(paste0("(", origFieldName[i], "-", center[i], ")", "/",
                                scale[i]))

  for(i in seq_along(eigenvector)) {
    empty_box <- pmmlTransformations::FunctionXform(empty_box,
                                                    origFieldName = origFieldName[i],
                                                    newFieldName = newFieldName[i],
                                                    formulaText = eval(formulaText))
  }
  empty_box
}

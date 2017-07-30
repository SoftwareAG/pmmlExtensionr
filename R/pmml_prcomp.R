#' Generates PMML for prcomp objects
#'
#' Extracts one principal component from a prcomp object together with the
#' centering and scaling information and generates the PMML representation.
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
#' @param n The number of the principal component for which the PMML will be created.
#'  Per default, the PMML will be constructed based on the eigenvector of the
#'  first principal component.
#' @param model.name	A name to be given to the model in the PMML code.
#' @param description	A descriptive text for the Header element of the PMML code.
#' @param ... Further arguments passed to \code{pmml.lm()} which make sense in
#'  the given context
#'
#' @return An object of class XMLnode which is of type PMML.
#' @export
pmml_prcomp <- function(model, n = 1, model.name = "Principal_Component_Model",
                        description = "Principal Component Model") {

  empty_df<- data.frame(matrix(data = rep(0, ncol(model$rotation) + 1),
                               nrow = 1, ncol = ncol(model$rotation) + 1))
  names(empty_df) <- c(row.names(model$rotation), paste0("PC", n))
  empty_box <- pmmlTransformations::WrapData(empty_df)

  origFieldName <-  row.names(model$rotation)
  newFieldName <- paste0(origFieldName, "_transformed")
  center <- model$center
  scale <- model$scale

  # Add centering and scaling as pre-processing steps to the WrapData object
  for(i in 1:nrow(model$rotation)) {
    empty_box <- pmmlTransformations::FunctionXform(empty_box,
                                                    origFieldName = origFieldName[i],
                                                    newFieldName = newFieldName[i],
                                                    formulaText = paste0("(", origFieldName[i], "-",
                                                                  center[i], ")", "/", scale[i]))
  }

  # Extract principal component coeffients
  pc_coef <- c("(Intercept)" = 0, model$rotation[, n])
  # Important to overwrite the original names with their "_transformed" version
  # so that adding of the WrapData object to pmml.lm() will work
  names(pc_coef)[2:length(pc_coef)] <- newFieldName
  dataClasses <- rep("numeric", length(pc_coef))
  names(dataClasses) <- names(pc_coef)
  names(dataClasses)[1] <- paste0("PC", n)

  fit <- list(coefficients = pc_coef, call = call("lm"), terms = NULL)
  attributes(fit$terms) <- list(dataClasses = dataClasses)
  class(fit) <- "lm"

  pmml <- pmml::pmml.lm(fit, model.name, description, transforms = empty_box,
                        ...)
}

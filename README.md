<!-- README.md is generated from README.Rmd. Please edit that file -->
pmmlExtensionr
==============

[![Build Status](https://travis-ci.org/SoftwareAG/pmmlExtensionr.svg?branch=master)](https://travis-ci.org/SoftwareAG/pmmlExtensionr) [![Build status](https://ci.appveyor.com/api/projects/status/99vd7jwrue71kx05/branch/master?svg=true)](https://ci.appveyor.com/project/alex23lemm/pmmlextensionr/branch/master)

Overview
--------

The goal of pmmlExtensionr is to convert specific R model types to PMML which are not yet supported by the standard [`pmml`](http://cran.r-project.org/web/packages/pmml/) package. To do so it leverages functionality of the [`pmmlTransformations`](http://cran.r-project.org/web/packages/pmmlTransformations/) package and of the `pmml` package itself.

The following model types are currently supported:

-   prcomp

Installation
------------

You can install pmmlExtensionr from GitHub with:

``` r

# install.packages("devtools")
devtools::install_github("alex23lemm/pmmlExtensionr")
```

Usage
-----

**prcomp**

`pmml_prcomp()` extracts one principal component from a prcomp object together with the centering and scaling information and generates the PMML representation.

``` r
library(pmmlExtensionr)

iris <- iris[, -5]
piris <- prcomp(iris, center = TRUE, scale. = TRUE)

# Create a PMML representation for the third eigenvector
pmml_prcomp(piris, 3)
```

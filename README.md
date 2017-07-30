<!-- README.md is generated from README.Rmd. Please edit that file -->
pmmlExtensionr
==============

Overview
--------

The goal of pmmlExtensionr is to convert specific R model types to PMML which are not yet supported by the standard [`pmml` package](http://cran.r-project.org/web/packages/pmml/). To do so it leverages functionality of the [`pmmlTransformations` package]((http://cran.r-project.org/web/packages/pmmlTransformations/)) and of the `pmml` package itself.

The following model types are currently supported:

-   `prcomp`

Installation
------------

You can install pmmlExtensionr from GitHub with:

``` r

# install.packages("devtools")
devtools::install_github("alex23lemm/pmmlExtensionr)
```

Example
-------

This is a basic example which shows you how to solve a common problem:

``` r
## basic example code
```

Related Work
------------

-   [`R2PMML` package](https://github.com/jpmml/r2pmml)

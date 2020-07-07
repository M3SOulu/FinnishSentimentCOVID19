# Requirements

* R (>= 3.6)
* Python (>= 3.5)
* libvoikko bindings for Python 3.

# Required R packages

The following R packages, available from CRAN, are required:
data.table, drake, magrittr, text2vec, caret, reticulate, glmnet,
devtools, stringr, stringi, cld3, logging, reticulate, jsonlite

They can be installed like this:

    install.packages(c("data.table", "drake", "magrittr", "text2vec",
                      "caret", "glmnet", "reticulate", "devtools",
                      "stringr", "stringi", "cld3", "logging",
                      "reticulate", "jsonlite")

The following packages developed by the authors are also required:
* EmoticonFindeR (https://github.com/M3SOulu/RSentiStrength)
* TextFeatures (https://github.com/M3SOulu/TextFeatures)
* RSentiStrength (https://github.com/M3SOulu/RSentiStrength)

A copy of these are included in this folder and can be installed likes
this:

    setwd("path/to/this/folder")
    devtools::install("packages/EmoticonFindeR")
    devtools::install("packages/TextFeatures")
    devtools::install("packages/RSentiStrength")

We also recommend installing the following version of the caret package, which
fixes a bug with glmnet and significantly improve the time required
for training the logisitic regression models:

    devtools::install_github("maelick/caret/pkg/caret")


# Running the scripts

Before running the script, it is required to build the plan with drake
(a make-like system for R to improve reproducibility of the experiments):

    setwd("path/to/this/folder")
    drake::r_make()

Once successful, the different scripts should all be able to run.
Here is the description of the different scripts:
* search\_tweets\_fi.R was the script run daily to extract tweets
* sample.R was used to create the random sample of tweets to annotate
* 01-performance.R produces the results for RQ1, RQ2 & RQ3.
* 02-predictions.R generates files with the disagreement between the
  annotators and the model that was used by the annotators for
  investigating those disagreements.
* 03-sentiment.R produces the figures for RQ3.

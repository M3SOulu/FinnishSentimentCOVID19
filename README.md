# FinnishSentimentCOVID19

This folder contains reproduction scripts for the paper "Sentiment
Analysis of Finnish Twitter Discussions on COVID-19 during the
Pandemic".

## Requirements

* R (>= 3.6)
* Python (>= 3.5)
* libvoikko bindings for Python 3.

## Required R packages

The following R packages, available from CRAN, are required:
data.table, drake, magrittr, text2vec, caret, reticulate, glmnet,
devtools, stringr, stringi, cld3, logging, reticulate, jsonlite, irrCAC

They can be installed like this:

    install.packages(c("data.table", "drake", "magrittr", "text2vec",
                      "caret", "glmnet", "reticulate", "devtools",
                      "stringr", "stringi", "cld3", "logging",
                      "reticulate", "jsonlite", "irrCAC")

The following packages developed by the authors are also required:
* EmoticonFindeR (https://github.com/M3SOulu/RSentiStrength)
* TextFeatures (https://github.com/M3SOulu/TextFeatures)
* RSentiStrength (https://github.com/M3SOulu/RSentiStrength)
* FinnishSentiment (https://github.com/M3SOulu/FinnishSentiment)

A copy of these are included in this folder and can be installed likes
this:

    setwd("path/to/this/folder")
    devtools::install_github("M3SOulu/EmoticonFindeR")
    devtools::install_github("M3SOulu/TextFeatures")
    devtools::install_github("M3SOulu/RSentiStrength")
    devtools::install_github("M3SOulu/FinnishSentiment")

We also recommend installing the following version of the caret package, which
fixes a bug with glmnet and significantly improve the time required
for training the logisitic regression models:

    devtools::install_github("maelick/caret/pkg/caret")


## Running the scripts

Before running the script, it is required to build the plan with drake
(a make-like system for R to improve reproducibility of the experiments):

    setwd("path/to/this/folder")
    drake::r_make()

Once successful, the different scripts should all be able to run.
Here is the description of the different scripts:
* search\_tweets\_fi.R was the script run daily to extract tweets
* sample.R was used to create the random sample of tweets to annotate
* 01-agreement.R produces the agreement rate between annotators.
* 01-sentistrength.R computes the prediction performance of Finnish
  SentiStrength (baseline).
* 03-evaluation_bi.R produces the prediction performance for the
  binomial models.
* 03-evaluation.R  produces the prediction performance for the
  multinomial models.
* 04-predictors.R produces the list of best predictors for the best
  multinomial model.
* 05-comparison_en.R produces the results for the English non-COVID-19
  model for RQ2.
* 06-sentiment.R produces the figures for RQ3.

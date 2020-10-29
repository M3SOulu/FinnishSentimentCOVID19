source("R/packages.R")
source("R/functions.R")
source("R/plan.R")
drake_config(plan,
             verbose=1,
             memory_strategy="preclean",
             log_make="drake.log",
             garbage_collection=TRUE)

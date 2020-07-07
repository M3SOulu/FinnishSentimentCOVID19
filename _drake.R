source("R/packages.R")
source("R/functions.R")
source("R/plan.R")
## future::plan(future::multiprocess)
## options(clustermq.scheduler="multicore")
drake_config(plan, verbose=1,
             ## parallelism="clustermq", jobs=4,
             ## parallelism="future", jobs=4,
             ## lock_envir=FALSE,
             memory_strategy="preclean",
             ## log_make="drake.log",
             garbage_collection=TRUE)

library(data.table)
library(xtable)
source("R/analysis.R")

m <- drake::drake_cache()$get("models.multi")$uni.ss.afinn$model
with(m$pred[grepl("Rep01$", m$pred$Resample), ], table(pred, obs))
xtable(with(m$pred[grepl("Rep01$", m$pred$Resample), ],
            table(pred, pred=obs), align="l|lll"))

models <- list(multi.all=drake::drake_cache()$get("semeval.multi.all"),
               multi.sample=drake::drake_cache()$get("semeval.multi.sample"),
               bi.all=drake::drake_cache()$get("semeval.bi.all"),
               bi.sample=drake::drake_cache()$get("semeval.bi.sample"))
models <- lapply(models, function(m) list(model=m))

perf <- rbind(t(sapply(models[1:2], MultinomialPerf)),
              t(sapply(models[-(1:2)], BinomialPerf)))
rownames(perf) <- c("3-class (all)", "3-class (sample)",
                    "2-class (all)", "2-class (sample)")
xtable(perf[, -which(colnames(perf) == "SD")], align="l|llll", digits=3)

with(models[[2]]$m$pred[grepl("Rep01$", m$pred$Resample), ], table(pred, obs))
xtable(with(models[[2]]$m$pred[grepl("Rep01$", m$pred$Resample), ], table(pred, obs)), align="l|lll")

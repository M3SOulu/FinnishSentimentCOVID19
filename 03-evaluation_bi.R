library(data.table)
library(magrittr)
library(xtable)
source("R/analysis.R")

models <- drake::drake_cache()$get("models.bi")

perf <- t(sapply(models, BinomialPerf))
perf <- cbind("# Features"=sapply(models, FeatureSize), perf)
rownames(perf) <- c("No Stemming", "Uni.", "Uni. + Bi.",
                    "SS", "SS Full", "AFINN", "AFINN Full",
                    "Uni. + SS", "Uni. + SS Full",
                    "Uni. + AFINN", "Uni. + AFINN Full",
                    "Uni. + SS + AFINN", "Uni. + SS Full + AFINN Full")
xtable(perf[, -which(colnames(perf) == "SD")], align="l|lllll", digits=3)

nostemming <- SelectCV(models$nostemming$model)$AUC
unigrams <- SelectCV(models$unigrams$model)$AUC
uni.ss <- SelectCV(models$uni.ss$model)$AUC
uni.afinn <- SelectCV(models$uni.afinn$model)$AUC
uni.ss.afinn <- SelectCV(models$uni.ss.afinn$model)$AUC

effsize::cohen.d(nostemming, unigrams)
t.test(nostemming, unigrams)

effsize::cohen.d(unigrams, uni.ss.afinn)
t.test(unigrams, uni.ss.afinn)

effsize::cohen.d(uni.ss, uni.ss.afinn)
t.test(uni.ss, uni.ss.afinn)

effsize::cohen.d(uni.afinn, uni.ss.afinn)
t.test(uni.afinn, uni.ss.afinn)

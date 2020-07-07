library(data.table)
library(magrittr)
library(xtable)
library(RSentiStrength)
library(caret)

## Sentiment analysis tools

tweets.fi <- drake::drake_cache()$get("annotations")
tweets.en <- drake::drake_cache()$get("semeval")

res <- SentiStrength(tweets.fi$text.clean, SentiStrengthData("sentidata_fi"))
table(obs=tweets.fi$polarity, pred=factor(with(res, RSentiStrength::Polarity(max, min)),
                                          levels=c(-1, 1, 0),
                                          labels=c("negative", "positive", "neutral")))
pol <- res[, factor(RSentiStrength::Polarity(max, min), levels=c(-1, 1, 0),
                    labels=c("negative", "positive", "neutral"))]
multiClassSummary(data.table(obs=tweets.fi$polarity, pred=pol), lev=levels(pol))

res <- RSentiStrength::SentiStrength(tweets.en$text)
table(obs=tweets.en$polarity, pred=with(res, RSentiStrength::Polarity(max, min)))
pol <- res[, factor(RSentiStrength::Polarity(max, min), levels=c(-1, 1, 0),
                    labels=c("negative", "positive", "neutral"))]
multiClassSummary(data.table(obs=tweets.en$polarity, pred=pol), lev=levels(pol))

res <- RSentiStrength::SentiStrength(tweets.en[(sample), text])
table(obs=tweets.en[(sample), polarity],
      pred=with(res, RSentiStrength::Polarity(max, min)))
pol <- res[, factor(RSentiStrength::Polarity(max, min), levels=c(-1, 1, 0),
                    labels=c("negative", "positive", "neutral"))]
multiClassSummary(data.table(obs=tweets.en[(sample), polarity], pred=pol),
                  lev=levels(pol))

## Models

models <- drake::drake_cache()$get("models.multi")

MultinomialPerf <- function(m) {
  m <- m$model
  perf <- m$resample[m$resample$lambda == m$bestTune$lambda, ]
  as.data.table(perf)[, list(AUC=mean(AUC), SD=sd(AUC),
                             Acc=mean(Accuracy), SD=sd(Accuracy),
                             BAcc=mean(Mean_Balanced_Accuracy),
                             SD=sd(Mean_Balanced_Accuracy),
                             F1=mean(Mean_F1), SD=sd(Mean_F1))]
}

perf <- t(sapply(models, MultinomialPerf))
FeatureSize <- function(m) nrow(coef(m$model$finalModel,
                                     s=m$model$bestTune$lambda)[[1]]) - 1
perf <- cbind("# Features"=sapply(models, FeatureSize), perf)
rownames(perf) <- c("No Stemming", "Uni.", "Uni. + Bi.",
                    "SS", "SS Full", "AFINN", "AFINN Full",
                    "Uni. + SS", "Uni. + SS Full",
                    "Uni. + AFINN", "Uni. + AFINN Full",
                    "Uni. + SS + AFINN", "Uni. + SS Full + AFINN Full")
xtable(perf[, -which(colnames(perf) == "SD")], align="l|lllll", digits=3)

m <- models$uni.ss.afinn$model
xtable(table(obs=m$pred$obs, pred=m$pred$pred), align="l|lll")

preds <- (coef(m$finalModel, s=m$bestTune$lambda) %>%
          lapply(as.matrix) %>%
          lapply(function(x) sort(x[x != 0 & rownames(x) != "(Intercept)", ])))
xtable(preds %>% sapply(function(x) c(names(head(x, 10)), names(tail(x, 10)))))
xtable(preds %>% sapply(function(x) rev(names(tail(x, 10)))))

models <- drake::drake_cache()$get("models.bi")

BinomialPerf <- function(m) {
  m <- m$model
  perf <- m$resample[m$resample$lambda == m$bestTune$lambda, ]
  as.data.table(perf)[, list(AUC=mean(AUC), SD=sd(AUC),
                             Acc=mean(Accuracy), SD=sd(Accuracy),
                             BAcc=mean(Balanced_Accuracy),
                             SD=sd(Balanced_Accuracy),
                             F1=mean(F1), SD=sd(F1))]
}

perf <- t(sapply(models, BinomialPerf))
FeatureSize <- function(m) nrow(coef(m$model$finalModel,
                                     s=m$model$bestTune$lambda)) - 1
perf <- cbind("# Features"=sapply(models, FeatureSize), perf)
rownames(perf) <- c("No Stemming", "Uni.", "Uni. + Bi.",
                    "SS", "SS Full", "AFINN", "AFINN Full",
                    "Uni. + SS", "Uni. + SS Full",
                    "Uni. + AFINN", "Uni. + AFINN Full",
                    "Uni. + SS + AFINN", "Uni. + SS Full + AFINN Full")
xtable(perf[, -which(colnames(perf) == "SD")], align="l|lllll", digits=3)

m <- models$uni.ss.afinn$model
table(m$pred$obs, m$pred$pred)

coef(m$finalModel, s=m$bestTune$lambda) %>%
as.matrix %>%
(function(x) sort(x[x != 0 & rownames(x) != "(Intercept)", ]))

models <- readRDS("output/english_models.rds")
models <- lapply(models, function(m) list(model=m))

perf <- rbind(t(sapply(models[1:2], MultinomialPerf)),
              t(sapply(models[-(1:2)], BinomialPerf)))
rownames(perf) <- c("3-class (all)", "3-class (sample)",
                    "2-class (all)", "2-class (sample)")
xtable(perf[, -which(colnames(perf) == "SD")], align="l|llll", digits=3)

lapply(models, function(m) table(m$model$pred$obs, m$model$pred$pred))

xtable(with(models$multi.sample$model$pred, table(obs, pred)), align="l|lll")

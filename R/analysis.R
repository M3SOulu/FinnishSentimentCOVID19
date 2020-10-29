SelectCV <- function(m) m$resample[m$resample$lambda == m$bestTune$lambda, ]

FeatureSize <- function(m) nrow(coef(m$model$finalModel,
                                     s=m$model$bestTune$lambda)[[1]]) - 1

MultinomialPerf <- function(m) {
  perf <- SelectCV(m$model)
  as.data.table(perf)[, list(AUC=mean(AUC), SD=sd(AUC),
                             Acc=mean(Accuracy), SD=sd(Accuracy),
                             BAcc=mean(Mean_Balanced_Accuracy),
                             SD=sd(Mean_Balanced_Accuracy),
                             F1=mean(Mean_F1), SD=sd(Mean_F1))]
}

BinomialPerf <- function(m) {
  perf <- SelectCV(m$model)
  as.data.table(perf)[, list(AUC=mean(AUC), SD=sd(AUC),
                             Acc=mean(Accuracy), SD=sd(Accuracy),
                             BAcc=mean(Balanced_Accuracy),
                             SD=sd(Balanced_Accuracy),
                             F1=mean(F1), SD=sd(F1))]
}

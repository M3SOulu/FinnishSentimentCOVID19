library(dta.table)

data <- drake::drake_cache()$get("annotations")

model <- drake::drake_cache()$get("models.multi")$uni.ss.afinn$model
preds <- model$pred[model$pred$lambda == model$bestTune$lambda, ]
preds <- cbind(data[, list(status_id, text)],
               preds[order(preds$rowIndex), c("obs", "pred")])
set.seed(42)
fwrite(preds[pred != obs][sample(.N, .N)], "output/predictions_multi.csv")

data <- data[!is.na(polarity2)]

model <- readRDS("output/binomial_models.rds")$uni.ss.afinn$model
preds <- model$pred[model$pred$lambda == model$bestTune$lambda, ]
preds <- cbind(data[, list(status_id, text)],
               preds[order(preds$rowIndex), c("obs", "pred")])
set.seed(42)
fwrite(preds[pred != obs][sample(.N, .N)], "output/predictions_bi.csv")

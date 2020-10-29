library(magrittr)
library(xtable)

model <- drake::drake_cache()$get("models.multi")$uni.ss.afinn$model

preds <- (coef(model$finalModel, s=model$bestTune$lambda) %>%
          lapply(as.matrix) %>%
          lapply(function(x) sort(x[x != 0 & rownames(x) != "(Intercept)", ])))
xtable(preds %>% sapply(function(x) rev(names(tail(x, 10)))))

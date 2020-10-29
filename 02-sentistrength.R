library(data.table)
library(RSentiStrength)
library(caret)

tweets <- drake::drake_cache()$get("annotations")

res <- SentiStrength(tweets$text.clean, SentiStrengthData("sentidata_fi"))
res[, polarity := factor(RSentiStrength::Polarity(max, min), levels=c(-1, 1, 0),
                         labels=c("negative", "positive", "neutral"))]
res[, polarity2 := factor(polarity, levels=c("negative", "positive"))]
table(obs=tweets$polarity, pred=res$polarity)
multiClassSummary(data.table(obs=tweets$polarity, pred=res$polarity), lev=levels(res$polarity))

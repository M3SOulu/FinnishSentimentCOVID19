library(data.table)

annotations <- drake::drake_cache()$get("raw.annotations")[Notes == ""]
nrow(annotations[!is.na(anna) & !is.na(minna) & !is.na(raija)])

nrow(annotations[is.na(anna) & !is.na(minna) & !is.na(raija)])
nrow(annotations[!is.na(anna) & is.na(minna) & !is.na(raija)])
nrow(annotations[!is.na(anna) & !is.na(minna) & is.na(raija)])

nrow(annotations[!is.na(anna) & is.na(minna) & is.na(raija)])
nrow(annotations[is.na(anna) & !is.na(minna) & is.na(raija)])
nrow(annotations[is.na(anna) & is.na(minna) & !is.na(raija)])

all <- annotations[!is.na(anna) & !is.na(minna) & !is.na(raija),
                   list(anna=as.numeric(factor(anna, levels=c("negative", "neutral", "positive"))) - 2,
                        minna=as.numeric(factor(minna, levels=c("negative", "neutral", "positive"))) - 2,
                        raija=as.numeric(factor(raija, levels=c("negative", "neutral", "positive"))) - 2)]

all <- annotations[!is.na(anna) & !is.na(minna) & !is.na(raija),
                   list(anna, minna, raija)]

irrCAC::krippen.alpha.raw(all, weights="unweighted")
irrCAC::krippen.alpha.raw(all, weights="quadratic")

psych::cohen.kappa(all)

library(data.table)

annotations <- drake::drake_cache()$get("raw.annotations")[Notes == ""]
nrow(annotations[!is.na(annotator1) & !is.na(annotator3) & !is.na(annotator2)])

nrow(annotations[is.na(annotator1) & !is.na(annotator3) & !is.na(annotator2)])
nrow(annotations[!is.na(annotator1) & is.na(annotator3) & !is.na(annotator2)])
nrow(annotations[!is.na(annotator1) & !is.na(annotator3) & is.na(annotator2)])

nrow(annotations[!is.na(annotator1) & is.na(annotator3) & is.na(annotator2)])
nrow(annotations[is.na(annotator1) & !is.na(annotator3) & is.na(annotator2)])
nrow(annotations[is.na(annotator1) & is.na(annotator3) & !is.na(annotator2)])

all <- annotations[!is.na(annotator1) & !is.na(annotator3) & !is.na(annotator2),
                   list(annotator1, annotator3, annotator2)]

irrCAC::krippen.alpha.raw(all, weights="unweighted")

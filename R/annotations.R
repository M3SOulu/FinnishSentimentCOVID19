AnnotationPolarity <- function(polarity) {
  factor(polarity, levels=c("+", "-", "0"),
         labels=c("positive", "negative", "neutral"))
}

ProcessAnnotations <- function(filename) {
  annotated <- fread(filename)
  annotated <- annotated[raija != "" | anna != "" | minna != ""]
  annotated[, anna:= AnnotationPolarity(anna)]
  annotated[, raija:= AnnotationPolarity(raija)]
  annotated[, minna:= AnnotationPolarity(minna)]
  PreprocessTweets(annotated)
}

PickRaija <- function(polarity, annotator) {
  if ("raija" %in% annotator) {
    which(annotator == "raija")
  } else {
    0
  }
}

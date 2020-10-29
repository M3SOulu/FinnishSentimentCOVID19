AnnotationPolarity <- function(polarity) {
  factor(polarity, levels=c("+", "-", "0"),
         labels=c("positive", "negative", "neutral"))
}

ProcessAnnotations <- function(filename) {
  annotated <- fread(filename)
  annotated <- annotated[annotator2 != "" | annotator1 != "" | annotator3 != ""]
  annotated[, annotator1 := AnnotationPolarity(annotator1)]
  annotated[, annotator2 := AnnotationPolarity(annotator2)]
  annotated[, annotator3 := AnnotationPolarity(annotator3)]
  PreprocessTweets(annotated)
}

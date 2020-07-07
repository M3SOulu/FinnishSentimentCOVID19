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

Vote1 <- function(polarity, annotator) {
  votes <- table(polarity)
  best <- which.max(votes)
  if (length(best) == 1) {
    which(polarity == names(best))[1]
  }
}

Vote2 <- function(polarity, annotator) {
  votes <- table(polarity)
  best <- which.max(votes)
  if (length(best) == 1) {
    which(polarity == names(best))[1]
  } else if ("positive" %in% names(best) && !"negative" %in% names(best)) {
    which(polarity == "positive")[1]
  } else if ("negative" %in% names(best) && !"positive" %in% names(best)) {
    which(polarity == "negative")[1]
  }
}

Vote3 <- function(polarity, annotator) {
  votes <- table(polarity)
  best <- which.max(votes)
  if (length(best) == 1) {
    which(polarity == names(best))[1]
  } else if ("neutral" %in% names(best)) {
    which(polarity == "neutral")[1]
  }
}

PickRaija <- function(polarity, annotator) {
  if ("raija" %in% annotator) {
    which(annotator == "raija")
  } else {
    0
  }
}

FavorNeutral <- function(polarity, annotator) {
  if (length(unique(polarity)) == 1) {
    1
  } else if (any(polarity == "neutral")) {
    which(polarity == "neutral")[1]
  }
}

FavorPolarity <- function(polarity, annotator) {
  if (length(unique(polarity)) == 1) {
    1
  } else if (any(polarity == "positive") & all(!polarity == "negative")) {
    which(polarity == "positive")[1]
  } else if (any(polarity == "negative") & all(!polarity == "positive")) {
    which(polarity == "negative")[1]
  } else if (any(polarity == "neutral")) {
    which(polarity == "neutral")[1]
  }
}

PickAnnotation <- function(annotations, PickFUNC) {
  data <- melt(annotations[lang == "fi"],
               measure.vars=c("raija", "minna", "anna"),
               variable.name="annotator", value.name="polarity")
  data <- data[!is.na(polarity)]
  data <- data[, .SD[PickFUNC(polarity, annotator)], by=status_id]
  data[, polarity2 := factor(polarity, levels=c("negative", "positive"))]
  data[, polarity := factor(polarity, levels=c("negative", "positive", "neutral"))]
  data
}

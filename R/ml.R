SemevalBaselineModel <- function(tweets, polarity.var="polarity") {
  with(tweets, {
    vocab <- TextFeatures::MakeVocabulary(tokens)
    dtm <- TextFeatures::MakeDTM(tokens, status_id, vocab)
    GlmnetCaret(dtm, tweets[[polarity.var]], allow.parallel=TRUE)
  })
}

Models <- function(features) {
  models <- with(features, lapply(names(features), function(f) {
    message("Training ", f)
    t <- system.time(m <- GlmnetCaret(features[[f]], response))
    list(time=t, model=m)
  }))
  names(models) <- names(features$features)
  models
}

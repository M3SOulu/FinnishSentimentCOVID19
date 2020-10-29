EnglishModel <- function(tweets, polarity.var="polarity", ...) {
  with(tweets, {
    vocab <- TextFeatures::MakeVocabulary(tokens)
    dtm <- TextFeatures::MakeDTM(tokens, status_id, vocab)
    cl <- makePSOCKcluster(2)
    registerDoParallel(cl)
    model <- GlmnetCaret(dtm, tweets[[polarity.var]], ...)
    stopCluster(cl)
    model
  })
}

Models <- function(features, ...) {
  cl <- makePSOCKcluster(2)
  registerDoParallel(cl)
  models <- with(features, lapply(names(features), function(f) {
    message("Training ", f)
    t <- system.time(m <- GlmnetCaret(features[[f]], response, ...))
    list(time=t, model=m)
  }))
  stopCluster(cl)
  names(models) <- names(features$features)
  models
}

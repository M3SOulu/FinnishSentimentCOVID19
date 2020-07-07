GlmnetCaret <- function(data, response, allow.parallel=TRUE) {
  control <- trainControl(method="repeatedcv",
                          number=10,
                          repeats=1,
                          returnResamp="all",
                          returnData=FALSE,
                          savePredictions="final",
                          classProbs=TRUE,
                          allowParallel=allow.parallel,
                          verboseIter=TRUE,
                          summaryFunction=multiClassSummary)
  grid <- expand.grid(alpha=1, lambda=seq(0.001, 0.1, by=0.001))
  set.seed(42)
  train(data, response, method="glmnet", trControl=control,
        weights=as.vector(length(response) / table(response)[response]),
        metric="AUC", tuneGrid=grid)
}

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

FinalModel <- function(tweets, lexicons) {
  vocab <- TextFeatures::MakeVocabulary(tweets$tokens.stemmed)
  features <- FinalFeatures(tweets, vocab, lexicons, tweets$status_id)
  list(vocab=vocab, model=GlmnetCaret(features, tweets$polarity))
}

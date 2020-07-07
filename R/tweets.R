Filenames <- function(datadir) {
  pattern <- "\\d\\d\\d\\d-\\d\\d-\\d\\d(-\\d\\d)?\\.rds$"
  dir(datadir, pattern=pattern, full.names=TRUE)
}

PreprocessTweets <- function(tweets) {
  tweets[, id := status_id]
  tweets[, lang_cld3 := cld3::detect_language(text)]
  tweets[, text.clean := Preprocess(text)]
  tweets
}

LoadTweets <- function(filename) {
  tweets <- readRDS(filename)
  PreprocessTweets(tweets)
}

SemevalTweets <- function(filename, sample.size) {
  tweets <- readRDS(filename)
  tweets[, text.clean := Preprocess(text)]
  tweets[, tokens := word_tokenizer(text.clean)]
  tweets[, polarity := factor(polarity, levels=c("negative", "positive", "neutral"))]
  tweets[, polarity2 := factor(polarity, levels=c("negative", "positive"))]

  set.seed(42)
  tweets[,
            sample := 1:.N %in% sample(.N, sample.size[polarity]),
            by=polarity]
  set.seed(42)
  tweets[!is.na(polarity2),
         sample2 := 1:.N %in% sample(.N, sample.size[polarity2]),
         by=polarity2]
  tweets
}

Sentiment <- function(tweets, model) {
  cbind(data.table(status_id=tweets$status_id,
                   polarity=FinnishSentiment(tweets, model)),
        FiSS(tweets$text.clean))
}

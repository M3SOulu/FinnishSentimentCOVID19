Filenames <- function(datadir) {
  pattern <- "\\d\\d\\d\\d-\\d\\d-\\d\\d(-\\d\\d)?\\.rds$"
  dir(datadir, pattern=pattern, full.names=TRUE)
}

PreprocessTweets <- function(tweets) {
  tweets[, lang_cld3 := cld3::detect_language(text)]
  tweets[, text.clean := (text %>% CleanText %>% RemoveHashtags %>%
                          ReplaceSpaces %>% tolower)]
  tweets
}

LoadTweets <- function(filename) {
  tweets <- readRDS(filename)
  PreprocessTweets(tweets)
}

SemevalTweets <- function(filename, sample.size) {
  tweets <- readRDS(filename)
  tweets[, text.clean := (text %>% CleanText %>% RemoveHashtags %>%
                          ReplaceSpaces %>% tolower)]
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

FinnishSentiment <- function(tweets, model, lexicons) {
  features <- FinalFeatures(tweets, model$vocab, lexicons)
  polarity <- predict(model$model, features)
  cbind(data.table(status_id=tweets$status_id,
                   polarity=polarity),
        FiSS(tweets$text.clean))
}

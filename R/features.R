FeatureSets <- function(tokens, tokens.stemmed, ids=1:length(tokens), lexicons) {
  vocab.nostemmed <- TextFeatures::MakeVocabulary(tokens)
  vocab.uni <- TextFeatures::MakeVocabulary(tokens.stemmed)
  vocab.bi <- TextFeatures::MakeVocabulary(tokens.stemmed, c(1, 2))
  with(lexicons, {
    list(nostemming=TextFeatures::MakeDTM(tokens, ids, vocab.nostemmed),
         unigrams=TextFeatures::MakeDTM(tokens.stemmed, ids, vocab.uni),
         bigrams=TextFeatures::MakeDTM(tokens.stemmed, ids, vocab.bi),
         ss.lexicon=MatchLexicon(tokens, lexicon.re, "SSLexicon", ids),
         ss.lexicon.full=MatchLexicon(tokens, lexicon.re.full,
                                      "SSLexicon", ids),
         afinn.lexicon=MatchLexicon(tokens.stemmed, lexicon2.re, "AFINN", ids),
         afinn.lexicon.full=MatchLexicon(tokens.stemmed, lexicon2.re.full,
                                         "AFINN", ids))
  })
}

TweetsFeatureSets <- function(tweets, lexicons, response.var="polarity") {
  features <- with(tweets, FeatureSets(tokens, tokens.stemmed,
                                       status_id, lexicons))
  features$uni.ss <- cbind(features$unigrams, features$ss.lexicon)
  features$uni.ss.full <- cbind(features$unigrams, features$ss.lexicon.full)
  features$uni.afinn <- cbind(features$unigrams, features$afinn.lexicon)
  features$uni.afinn.full <- cbind(features$unigrams,
                                   features$afinn.lexicon.full)
  features$uni.ss.afinn <- cbind(features$unigrams, features$ss.lexicon,
                                 features$afinn.lexicon)
  features$uni.ss.afinn.full <- cbind(features$unigrams,
                                      features$ss.lexicon.full,
                                      features$afinn.lexicon.full)
  list(features=features, response=tweets[[response.var]])
}

Features <- function(tweets, vocab, lexicons) {
  dtm <- TextFeatures::MakeDTM(tweets$tokens.stemmed, tweets$status_ids, vocab)
  ss.lexicon <- MatchLexicon(tweets$tokens, lexicons$lexicon.re,
                             "SSLexicon", tweets$status_id)
  afinn.lexicon <- MatchLexicon(tweets$tokens.stemmed, lexicons$lexicon2.re,
                                "AFINN", tweets$status_id)
  cbind(dtm, ss.lexicon, afinn.lexicon)
}

FinalFeatures <- function(tweets, vocab, lexicons, ids=NULL) {
  if (is.character(tweets)) {
    tweets <- data.table(text=tweets)
    message("Processing tweets")
    tweets[, text.clean := (text %>% CleanText %>% RemoveHashtags %>%
                            ReplaceSpaces %>% tolower)]
    tweets <- ProcessFinnish(tweets)
  }
  if (is.list(tweets)) {
    message("Computing DTM")
    dtm <- TextFeatures::MakeDTM(tweets$tokens.stemmed, ids, vocab)
    message("Matching SS Lexicon")
    ss.lexicon <- MatchLexicon(tweets$tokens, lexicons$lexicon.re,
                               "SSLexicon", ids)
    message("Matching AFINN Lexicon")
    afinn.lexicon <- MatchLexicon(tweets$tokens.stemmed, lexicons$lexicon2.re,
                                  "AFINN", ids)
    cbind(dtm, ss.lexicon, afinn.lexicon)
  } else {
    stop("Wrong type for text features ", class(tweets))
  }
}

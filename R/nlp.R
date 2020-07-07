## ProcessFinnish <- function(tweets) {
##   tweets[, tokens := TokenizeWithEmojis(text.clean)]
##   voikko <- reticulate::import("libvoikko")$Voikko("fi-x-standard")
##   tweets[, voikko := lapply(tokens, VoikkoStemTokens, voikko)]
##   tweets[, tokens.stemmed := mapply(function(tokens, voikko) {
##     mapply(function(t, v) {
##       tolower(if (length(v) == 0) t else v[[1]]$BASEFORM)
##     }, tokens, voikko)
##   }, tokens, voikko, SIMPLIFY=FALSE)]
##   tweets
## }

## RemoveURL <- function(text) gsub("https?://[[:graph:]]*", "<url>", text)

## CleanText <- function(text) {
##   text <- RemoveURL(text)
##   text <- stringr::str_replace_all(text,"[^[:graph:]\n\r]", " ")
##   gsub("(^ +)|( +$)", "", text)
## }

## ReplaceSpaces <- function(text) {
##   gsub("[[:space:]]+", " ", text)
## }

## RemoveHashtags <- function(text) {
##   gsub("#", " ", text)
## }

## TokenizeWithEmojis <- function(text) {
##   emojis <- EmoticonFindeR::FindUnicodeEmojis(text)
##   emojis <- emojis[, list(from=list(sort(c(1, start, start + 1))),
##                           end=list(sort(c(start - 1, start, nchar(text))))),
##                    by=list(id, text)]
##   emojis[, text.split := stringi::stri_sub_all(text, from, end)]
##   emojis[, tokens := lapply(text.split, function(text) {
##     unlist(lapply(text, function(t) {
##       if (t %in% EmoticonFindeR::emojis$char) {
##         t
##       } else if (t != "") {
##         word_tokenizer(t)
##       }
##     }))
##   })]
##   tokens <- word_tokenizer(text)
##   tokens[emojis$id] <- emojis$tokens
##   tokens
## }

## VoikkoStemTokens <- function(tokens, voikko=NULL) {
##   if (is.null(voikko)) {
##     libvoikko <- reticulate::import("libvoikko")
##     voikko <- libvoikko$Voikko("fi-x-standard")
##   }
##   lapply(tokens, voikko$analyze)
## }

FiSS <- function(text) {
  ssdata <- RSentiStrength::SentiStrengthData("sentidata_fi")
  res <- RSentiStrength::SentiStrength(text, ssdata)
  res[, polarity.ss := RSentiStrength::Polarity(max, min)]
  res[, polarity.ss := factor(polarity.ss, levels=c(-1, 1, 0),
                              labels=c("negative", "positive", "neutral"))]
  res
}

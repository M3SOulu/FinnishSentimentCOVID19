Pattern2Regex <- function(pattern) {
  prefix <- grep("\\*$", pattern)
  if (length(prefix)) {
    no.prefix <- paste(pattern[-prefix], collapse="|")
    prefix <- paste(sub("\\*$", "", pattern[prefix]), collapse="|")
    if (nchar(prefix) && nchar(no.prefix)) sprintf("((^| )(%s))|((^| )%s($| ))", prefix, no.prefix)
    else if (nchar(prefix)) sprintf("(^| )(%s)", prefix)
  } else {
    sprintf("(^| )(%s)($| )", paste(pattern, collapse="|"))
  }
}

LoadLexicons <- function(ss.filename, filename2) {
  lexicon <- fread(ss.filename, col.names=c("pattern", "value"))
  lexicon <- unique(lexicon)[, {
    if (.N == 1) .SD
    else if (all(value > 0)) list(value=max(value))
    else if (all(value < 0)) list(value=min(value))
  }, by=pattern]
  lexicon.re.full <- lexicon[, list(regex=Pattern2Regex(pattern)), by=value]
  lexicon.re.full <- lexicon.re.full[order(value)]

  lexicon.re <- lexicon[abs(value) > 1, list(value=value / abs(value), pattern)]
  lexicon.re <- lexicon.re[, list(regex=Pattern2Regex(pattern)), by=value]
  lexicon.re <- lexicon.re[order(value)]

  lexicon2 <- unlist(jsonlite::read_json(filename2))
  lexicon2 <- data.table(pattern=names(lexicon2), value=lexicon2)[value != 0]
  lexicon2.re.full <- lexicon2[, list(regex=Pattern2Regex(pattern)), by=value]
  lexicon2.re.full <- lexicon2.re.full[order(value)]

  lexicon2.re <- lexicon2[, list(value=value / abs(value), pattern)]
  lexicon2.re <- lexicon2.re[, list(regex=Pattern2Regex(pattern)), by=value]
  lexicon2.re <- lexicon2.re[order(value)]

  list(lexicon=lexicon, lexicon.re=lexicon.re, lexicon.re.full=lexicon.re.full,
       lexicon2=lexicon2, lexicon2.re=lexicon2.re, lexicon2.re.full=lexicon2.re.full)
}

MatchLexicon <- function(tokens, lexicon, lexicon.name=NULL, ids=NULL) {
  tokens <- sapply(tokens, paste, collapse=" ")
  Count <- function(regex) stringr::str_count(tokens, regex)
  res <- sapply(lexicon$regex, Count)
  colnames(res) <- lexicon$value
  if (!is.null(lexicon.name)) {
    colnames(res) <- paste(lexicon.name, colnames(res), sep="_")
  }
  if (!is.null(ids)) {
    rownames(res) <- as.character(ids)
  }
  res
}

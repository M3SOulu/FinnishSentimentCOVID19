library(data.table)

datadir <- "data/raw"
logging::basicConfig()

RangeFilter <- function(from, to) {
  dates <- seq(as.Date(from), as.Date(to), by="day")
  function(files) {
    files[as.Date(basename(files)) %in% dates]
  }
}

GetSample <- function(tweets, size=5000) {
  tweets <- tweets[(!is_retweet) & !duplicated(text), list(status_id, text)]
  set.seed(42)
  tweets[sample(.N, size)]
}

tweets <- drake::drake_cache()$get("tweets.fi")
tweets <- tweets[created_at >= "2020-04-22" & created_at <= "2020-05-11"]
sample <- GetSample(tweets)

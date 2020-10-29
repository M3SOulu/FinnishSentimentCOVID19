library(data.table)
library(rtweet)
library(magrittr)

ConvertTime <- function(time, format, tz.in="UTC", tz.out="UTC") {
  time %>% strftime(format, tz=tz.in) %>% strptime(format, tz=tz.out)
}

TimeRange <- function(datadir, by="days") {
  if (by == "days") {
    pattern <- "\\d\\d\\d\\d-\\d\\d-\\d\\d\\.rds$"
    format <- "%Y-%m-%d"
  } else if (by == "hours") {
    pattern <- "\\d\\d\\d\\d-\\d\\d-\\d\\d\\-\\d\\d.rds$"
    format <- "%Y-%m-%d-%H"
  } else {
    stop("Invalid argument by: ", by)
  }

  files <- dir(datadir, pattern=pattern)
  if (length(files)) {
    from.time <- max(files) %>% strptime(format, tz="UTC") + as.difftime(1, units=by)
  } else {
    from.time <- ConvertTime(Sys.time(), format) - as.difftime(10, units="days")
  }
  to.time <- ConvertTime(Sys.time(), format) - as.difftime(1, units=by)
  seq(from.time, to.time, by=by)
}

SearchTweets <- function(query, time, ntweets=18000,
                         tweets=NULL, last=NULL, ...) {
  while (min(tweets$created_at) >= time) {
    message(sprintf("Fetching %d tweets for %s", ntweets, query))
    res <- as.data.table(search_tweets(query, ntweets, max_id=last,
                                       retryonratelimit=TRUE, ...))
    message(sprintf("Got %d tweets", nrow(res)))
    if (nrow(res)) {
      tweets <- rbind(tweets, res)
      message(sprintf("First tweet from %s", max(res$created_at)))
      message(sprintf("Last tweet from %s", min(tweets$created_at)))
      last <- min(tweets$status_id)
    }
  }
  tweets
}

SaveTweets <- function(tweets, times, datadir, by="days") {
  if (by == "days") {
    format <- "%Y-%m-%d"
  } else if (by == "hours") {
    format <- "%Y-%m-%d-%H"
  } else {
    stop("Invalid argument by: ", by)
  }
  for (t in strftime(times, format, tz="UTC")) {
    filename <- file.path(datadir, sprintf("%s.rds", t))
    t <- strptime(t, format, tz="UTC")
    message(sprintf("Saving tweets for %s", t))
    saveRDS(tweets[ConvertTime(created_at, format) == t], filename)
  }
}

logging::basicConfig()

datadir <- "./data/raw/fi"
query <- "covid OR corona OR korona OR pandemi OR epidemi"

message("Finnish tweets")
times <- TimeRange(datadir)
message("from: ", min(times))
message("to: ", max(times))

tweets <- SearchTweets(query, min(times), lang="fi")
tweets <- tweets[!duplicated(status_id)]

SaveTweets(tweets, times, datadir)

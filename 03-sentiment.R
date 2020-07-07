source("functions.R")
source("R/lexicons.R")
source("R/ml.R")

data <- drake::drake_cache()$get("annotations")
lexicons <- drake::drake_cache()$get("lexicons")

tweets <- merge(drake::drake_cache()$get("tweets.fi"),
                drake::drake_cache()$get("sentiment.fi"),
                by="status_id")[!is_retweet & lang_cld3 == "fi"]

tweets[, date := as.Date(created_at)]
data <- melt(tweets[, c(as.list(table(polarity))), by=date], id.vars="date")
data[, ratio := value / sum(value), by=date]
data <- data[, value.roll := frollmean(value, 7), by=variable]
data <- data[, ratio.roll := frollmean(ratio, 7), by=variable]

pdf("output/evolution_ratio.pdf", width=6, height=4)
qplot(date, ratio.roll, group=variable, color=variable, geom="line",
      data=data[!is.na(ratio.roll)]) +
theme_light() +
scale_x_date(date_breaks="1 week") +
theme(axis.text.x=element_text(angle=45, hjust=1)) +
xlab("Date") + ylab("Ratio of daily tweets")
dev.off()

pdf("output/evolution.pdf", width=6, height=4)
qplot(date, value.roll, group=variable, color=variable, geom="line",
      data=data[!is.na(value.roll)]) +
theme_light() +
scale_x_date(date_breaks="1 week") +
theme(axis.text.x=element_text(angle=45, hjust=1)) +
xlab("Date") + ylab("# daily tweets")
dev.off()

data <- melt(tweets[, c(as.list(table(polarity.ss))), by=date], id.vars="date")
data[, ratio := value / sum(value), by=date]
data <- data[, value.roll := frollmean(value, 7), by=variable]
data <- data[, ratio.roll := frollmean(ratio, 7), by=variable]

pdf("output/evolution_ratio_ss.pdf", width=6, height=4)
qplot(date, ratio.roll, group=variable, color=variable, geom="line",
      data=data[!is.na(ratio.roll)]) +
theme_light() +
scale_x_date(date_breaks="1 week") +
theme(axis.text.x=element_text(angle=45, hjust=1)) +
xlab("Date") + ylab("Ratio of daily tweets")
dev.off()

pdf("output/evolution_ss.pdf", width=6, height=4)
qplot(date, value.roll, group=variable, color=variable, geom="line",
      data=data[!is.na(value.roll)]) +
theme_light() +
scale_x_date(date_breaks="1 week") +
theme(axis.text.x=element_text(angle=45, hjust=1)) +
xlab("Date") + ylab("# daily tweets")
dev.off()

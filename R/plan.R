datadir <- "data"
logging::basicConfig()

files.all <- Filenames(file.path(datadir, "raw/all"))
files.fi <- Filenames(file.path(datadir, "raw/fi"))
files.sv <- Filenames(file.path(datadir, "raw/sv"))

plan <- drake_plan(#max_expand=5,
                   subtweets.all=target(LoadTweets(file_in(filename)),
                                        transform=map(filename=!!files.all)),
                   subtweets.fi=target((LoadTweets(file_in(filename)) %>%
                                        ProcessFinnish),
                                       transform=map(filename=!!files.fi)),
                   subtweets.sv=target(LoadTweets(file_in(filename)),
                                       transform=map(filename=!!files.sv)),
                   raw.annotations=ProcessAnnotations(!!file.path(datadir, "annotations.csv")),
                   annotations=PickAnnotation(raw.annotations, FavorPolarity) %>% ProcessFinnish,
                   semeval=SemevalTweets(!!file.path(datadir, "semeval/tweets.rds"),
                                         table(annotations$polarity)),
                   semeval.multi.all=SemevalBaselineModel(semeval),
                   semeval.multi.sample=SemevalBaselineModel(semeval[(sample)]),
                   semeval.bi.all=SemevalBaselineModel(semeval[!is.na(polarity2)], "polarity2"),
                   semeval.bi.sample=SemevalBaselineModel(semeval[!is.na(polarity2) & sample2], "polarity2"),
                   lexicons=Lexicons(),
                   features.multi=TweetsFeatureSets(annotations, lexicons),
                   models.multi=Models(features.multi),
                   features.bi=TweetsFeatureSets(annotations[!is.na(polarity2)],
                                                 lexicons, "polarity2"),
                   models.bi=Models(features.bi),
                   final.model=Model(annotations, lexicons),
                   tweets.all=target(rbindlist(list(subtweets.all)),
                                     transform=combine(subtweets.all)),
                   tweets.sv=target(rbindlist(list(subtweets.sv)),
                                    transform=combine(subtweets.sv)),
                   subsentiment.fi=target(Sentiment(subtweets.fi, final.model),
                                          transform=map(subtweets.fi)),
                   tweets.fi=target(rbindlist(list(subtweets.fi)),
                                    transform=combine(subtweets.fi)),
                   sentiment.fi=target(rbindlist(list(subsentiment.fi)),
                                       transform=combine(subsentiment.fi)))

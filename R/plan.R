datadir <- "data"
logging::basicConfig()

files.fi <- Filenames(file.path(datadir, "raw/fi"))

ss.lexicon <- file.path(datadir, "lexicons/sentidata_fi/EmotionLookupTable.txt")
afinn.lexicon <- file.path(datadir, "lexicons/AFINN_fiLabels.json")

plan <- drake_plan(subtweets.fi=target((LoadTweets(file_in(filename)) %>%
                                        ProcessFinnish),
                                       transform=map(filename=!!files.fi)),
                   raw.annotations=ProcessAnnotations(!!file.path(datadir, "annotations.csv")),
                   annotations=PickAnnotation(raw.annotations, FavorPolarity) %>% ProcessFinnish,
                   semeval=SemevalTweets(!!file.path(datadir, "semeval/tweets.rds"),
                                         table(annotations$polarity)),
                   semeval.multi.all=SemevalBaselineModel(semeval),
                   semeval.multi.sample=SemevalBaselineModel(semeval[(sample)]),
                   semeval.bi.all=SemevalBaselineModel(semeval[!is.na(polarity2)], "polarity2"),
                   semeval.bi.sample=SemevalBaselineModel(semeval[!is.na(polarity2) & sample2], "polarity2"),
                   lexicons=LoadLexicons(!!ss.lexicon, !!afinn.lexicon),
                   features.multi=TweetsFeatureSets(annotations, lexicons),
                   models.multi=Models(features.multi),
                   features.bi=TweetsFeatureSets(annotations[!is.na(polarity2)],
                                                 lexicons, "polarity2"),
                   models.bi=Models(features.bi),
                   final.model=FinalModel(annotations, lexicons),
                   subsentiment.fi=target(FinnishSentiment(subtweets.fi,
                                                           final.model,
                                                           lexicons),
                                          transform=map(subtweets.fi)),
                   tweets.fi=target(rbindlist(list(subtweets.fi)),
                                    transform=combine(subtweets.fi)),
                   sentiment.fi=target(rbindlist(list(subsentiment.fi)),
                                       transform=combine(subsentiment.fi)))

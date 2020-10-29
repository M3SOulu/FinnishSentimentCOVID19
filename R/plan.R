datadir <- "data"
logging::basicConfig()

files.all <- Filenames(file.path(datadir, "raw/all"))
files.fi <- Filenames(file.path(datadir, "raw/fi"))
files.sv <- Filenames(file.path(datadir, "raw/sv"))

plan <- drake_plan(#max_expand=5,
                   subtweets.fi=target((LoadTweets(file_in(filename)) %>%
                                        ProcessFinnish),
                                       transform=map(filename=!!files.fi)),
                   raw.annotations=ProcessAnnotations(file_in(!!file.path(datadir, "annotations.csv"))),
                   raw.annotations.all=raw.annotations[!is.na(anna) & !is.na(minna) & !is.na(raija)],
                   annotations=(PickAnnotation(raw.annotations, Vote2) %>% ProcessFinnish)[Notes == ""],
                   annotations.all=(PickAnnotation(raw.annotations.all, Vote2) %>% ProcessFinnish)[Notes == ""],
                   semeval=SemevalTweets(!!file.path(datadir, "semeval/tweets.rds"),
                                         table(annotations$polarity)),
                   semeval.multi.all=EnglishModel(semeval, repeats=10, allow.parallel=TRUE),
                   semeval.multi.sample=EnglishModel(semeval[(sample)], repeats=10, allow.parallel=TRUE),
                   semeval.bi.all=EnglishModel(semeval[!is.na(polarity2)], "polarity2", repeats=10, allow.parallel=TRUE),
                   semeval.bi.sample=EnglishModel(semeval[!is.na(polarity2) & sample2], "polarity2", repeats=10, allow.parallel=TRUE),
                   lexicons=Lexicons(),
                   features.multi=TweetsFeatureSets(annotations, lexicons),
                   models.multi=Models(features.multi, repeats=10, allow.parallel=TRUE),
                   features.bi=TweetsFeatureSets(annotations[!is.na(polarity2)],
                                                 lexicons, "polarity2"),
                   models.bi=Models(features.bi, repeats=10, allow.parallel=TRUE),
                   features.all.multi=TweetsFeatureSets(annotations.all, lexicons),
                   models.all.multi=Models(features.all.multi, repeats=10, allow.parallel=TRUE),
                   features.all.bi=TweetsFeatureSets(annotations.all[!is.na(polarity2)],
                                                     lexicons, "polarity2"),
                   models.all.bi=Models(features.all.bi, repeats=10, allow.parallel=TRUE),
                   final.model=Model(annotations, lexicons, repeats=10, allow.parallel=TRUE),
                   final.model.all=Model(annotations.all, lexicons, repeats=10, allow.parallel=TRUE),
                   subsentiment.fi=target(Sentiment(subtweets.fi, final.model),
                                          transform=map(subtweets.fi)),
                   subsentiment.fi.all=target(Sentiment(subtweets.fi, final.model.all),
                                              transform=map(subtweets.fi)),
                   tweets.fi=target(rbindlist(list(subtweets.fi)),
                                    transform=combine(subtweets.fi)),
                   sentiment.fi=target(rbindlist(list(subsentiment.fi)),
                                       transform=combine(subsentiment.fi)),
                   sentiment.fi.all=target(rbindlist(list(subsentiment.fi.all)),
                                           transform=combine(subsentiment.fi.all)))

loadJapanese <- function() {

  # Yuuka Kinoshita
  df.yuuka.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ja/YukaKinoshita/YukaKinoshita_observed_dependencies.csv",
                                             header=TRUE, sep=","))
  df.yuuka.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ja/YukaKinoshita/YukaKinoshita_optimal_dependencies.csv",
                                             header=TRUE, sep=","))
  df.yuuka.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ja/YukaKinoshita/YukaKinoshita_random_dependencies.csv",
                                             header=TRUE, sep=","))
  df.yuuka <- bind_rows(list("Observed"=df.yuuka.observed, "Optimal"=df.yuuka.optimal, 
                             "Random"=df.yuuka.random),  .id = 'baseline')

  # Hikakin
  df.hikakin.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ja/HikakinTV/HikakinTV_observed_dependencies.csv", 
                                               header=TRUE, sep=","))
  df.hikakin.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ja/HikakinTV/HikakinTV_optimal_dependencies.csv",  
                                               header=TRUE, sep=","))
  df.hikakin.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ja/HikakinTV/HikakinTV_random_dependencies.csv",   
                                               header=TRUE, sep=","))
  df.hikakin <- bind_rows(list("Observed"=df.hikakin.observed, "Optimal"=df.hikakin.optimal, 
                               "Random"=df.hikakin.random),  .id = 'baseline')

 # Fischer's (uncorrected)
  df.fischers.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ja/Fischers/Fischers_observed_dependencies.csv",
                                                header=TRUE, sep=","))
  df.fischers.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ja/Fischers/Fischers_optimal_dependencies.csv",
                                                header=TRUE, sep=","))
  df.fischers.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ja/Fischers/Fischers_random_dependencies.csv", 
                                                header=TRUE, sep=","))
  df.fischers <- bind_rows(list("Observed"=df.fischers.observed, "Optimal"=df.fischers.optimal,
                                "Random"=df.fischers.random),  .id = 'baseline')
  
  # Fischer's (corrected)
  df.fischers.hc.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/manual/ja/Fischers/Fischers_observed_dependencies.csv",
                                                   header=TRUE, sep=","))
  df.fischers.hc.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/manual/ja/Fischers/Fischers_optimal_dependencies.csv",
                                                   header=TRUE, sep=","))
  df.fischers.hc.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/manual/ja/Fischers/Fischers_random_dependencies.csv", 
                                                   header=TRUE, sep=","))
  df.fischers.hc <- bind_rows(list("Observed"=df.fischers.hc.observed, "Optimal"=df.fischers.hc.optimal,
                                   "Random"=df.fischers.hc.random),  .id = 'baseline')
  
  # Hajime Shachoo
  df.hajime.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ja/HajimeShachoo/HajimeShachoo_observed_dependencies.csv",
                                              header=TRUE, sep=","))
  df.hajime.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ja/HajimeShachoo/HajimeShachoo_optimal_dependencies.csv",
                                              header=TRUE, sep=","))
  df.hajime.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ja/HajimeShachoo/HajimeShachoo_random_dependencies.csv",
                                              header=TRUE, sep=","))
  df.hajime <- bind_rows(list("Observed"=df.hajime.observed, "Optimal"=df.hajime.optimal, 
                              "Random"=df.hajime.random),  .id = 'baseline')

  # Tokai on Air
  df.tokai.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ja/TokaiOnAir/TokaiOnAir_observed_dependencies.csv",
                                             header=TRUE, sep=","))
  df.tokai.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ja/TokaiOnAir/TokaiOnAir_optimal_dependencies.csv",
                                             header=TRUE, sep=","))
  df.tokai.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ja/TokaiOnAir/TokaiOnAir_random_dependencies.csv", 
                                             header=TRUE, sep=","))
  df.tokai <- bind_rows(list("Observed"=df.tokai.observed, "Optimal"=df.tokai.optimal, 
                             "Random"=df.tokai.random),  .id = 'baseline')
  
  # Bind data
  df.all.jp <- bind_rows(list("Yuka"=df.yuuka, 
                              "FischersAuto"=df.fischers,
                              "FischersCorrected"=df.fischers.hc,
                              "Hajime"=df.hajime, 
                              "Hikakin"=df.hikakin,
                              "Tokai"=df.tokai), .id = 'channel')
  
  # Calculate squared sentence length to match Futrell et al.: better predictor than raw length
  df.all.jp$sent_len_sq   <- df.all.jp$total_length * df.all.jp$total_length
  
  # Create index variables: r = 1 if random; 0 else, m = 1 if optimal; 0 else
  df.all.jp$baseline <- factor(df.all.jp$baseline, levels=c("Random", "Optimal", "Observed")) 
  df.all.jp <- df.all.jp %>% mutate(r = as.integer(baseline == "Random"), m = as.integer(baseline == "Optimal"), o = as.integer(baseline == "Observed"))
  
  # Factors index variables
  df.all.jp$r <- factor(df.all.jp$r) 
  df.all.jp$o <- factor(df.all.jp$o) 
  df.all.jp$m <- factor(df.all.jp$m) 
  
  # Unique ids for each sentence
  df.all.jp <- df.all.jp %>% mutate(sentence_uid = paste(channel, video_id, sentence_id, sep="_"))
  df.all.jp$sentence_uid <- factor(df.all.jp$sentence_uid)
  df.all.jp$channel <- factor(df.all.jp$channel)
  
  return(df.all.jp)
}
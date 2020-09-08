loadTurkish <- function() {
  
  # Sumeyra
  df.sumeyra.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/Sumeyra/Sumeyra_observed_dependencies.csv",
                                            header=TRUE, sep=","))
  df.sumeyra.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/Sumeyra/Sumeyra_optimal_dependencies.csv",
                                            header=TRUE, sep=","))
  df.sumeyra.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/Sumeyra/Sumeyra_random_dependencies.csv",
                                            header=TRUE, sep=","))
  df.sumeyra <- bind_rows(list("Observed"=df.sumeyra.observed, "Optimal"=df.sumeyra.optimal, 
                            "Random"=df.sumeyra.random),  .id = 'baseline')
  
  # sencalkapimi
  df.sencalkapimi.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/SenCalKapimi/SenCalKapimi_observed_dependencies.csv",
                                               header=TRUE, sep=","))
  df.sencalkapimi.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/SenCalKapimi/SenCalKapimi_optimal_dependencies.csv",
                                               header=TRUE, sep=","))
  df.sencalkapimi.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/SenCalKapimi/SenCalKapimi_random_dependencies.csv",
                                               header=TRUE, sep=","))
  df.sencalkapimi <- bind_rows(list("Observed"=df.sencalkapimi.observed, "Optimal"=df.sencalkapimi.optimal, 
                               "Random"=df.sencalkapimi.random),  .id = 'baseline')
  
  # Bind data
  df.all.tr <- bind_rows(list("Sumeyra"=df.sumeyra,
                              "SenCalKapimi"=df.sencalkapimi), .id = 'channel')
  
  # Calculate squared sentence length to match Futrell et al.: better predictor than raw length
  df.all.tr$sent_len_sq   <- df.all.tr$total_length * df.all.tr$total_length
  
  # Create index variables: ri = 1 if random; 0 else, mi = 1 if optimal; 0 else
  df.all.tr$baseline <- factor(df.all.tr$baseline, levels=c("Random", "Optimal", "Observed")) 
  df.all.tr <- df.all.tr %>% mutate(r = as.integer(baseline == "Random"), m = as.integer(baseline == "Optimal"), o = as.integer(baseline == "Observed"))
  
  
  # Factors index variables
  df.all.tr$r <- factor(df.all.tr$r) 
  df.all.tr$o <- factor(df.all.tr$o) 
  df.all.tr$m <- factor(df.all.tr$m) 
  
  # Unique ids for each sentence
  df.all.tr <- df.all.tr %>% mutate(sentence_uid = paste(channel, video_id, sentence_id, sep="_"))
  df.all.tr$sentence_uid <- factor(df.all.tr$sentence_uid)
  df.all.tr$channel <- factor(df.all.tr$channel)
  
  return(df.all.tr)
}
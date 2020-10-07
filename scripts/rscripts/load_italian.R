loadItalian <- function() {
  
  # Other
  df.other.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/it/Other/Other_observed_dependencies.csv",
                                                   header=TRUE, sep=","))
  df.other.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/it/Other/Other_optimal_dependencies.csv",
                                                   header=TRUE, sep=","))
  df.other.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/it/Other/Other_random_dependencies.csv",
                                                   header=TRUE, sep=","))
  df.other <- bind_rows(list("Observed"=df.other.observed, "Optimal"=df.other.optimal, 
                                   "Random"=df.other.random),  .id = 'baseline')
  
  # Scottecs
  df.scottecs.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/it/Scottecs/Scottecs_observed_dependencies.csv",
                                              header=TRUE, sep=","))
  df.scottecs.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/it/Scottecs/Scottecs_optimal_dependencies.csv",
                                              header=TRUE, sep=","))
  df.scottecs.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/it/Scottecs/Scottecs_random_dependencies.csv",
                                              header=TRUE, sep=","))
  df.scottecs <- bind_rows(list("Observed"=df.scottecs.observed, "Optimal"=df.scottecs.optimal, 
                              "Random"=df.scottecs.random),  .id = 'baseline')
  
  # TheJakal
  df.thejakal.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/it/TheJakal/TheJakal_observed_dependencies.csv",
                                            header=TRUE, sep=","))
  df.thejakal.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/it/TheJakal/TheJakal_optimal_dependencies.csv",
                                            header=TRUE, sep=","))
  df.thejakal.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/it/TheJakal/TheJakal_random_dependencies.csv",
                                            header=TRUE, sep=","))
  df.thejakal <- bind_rows(list("Observed"=df.thejakal.observed, "Optimal"=df.thejakal.optimal, 
                            "Random"=df.thejakal.random),  .id = 'baseline')
  
  
  # Bind data
  df.all.it <- bind_rows(list("Other"=df.other,
                              "Scottecs"=df.scottecs,
                              "TheJakal"=df.thejakal), .id = 'channel')
  
  # Calculate squared sentence length to match Futrell et al.: better predictor than raw length
  df.all.it$sent_len_sq   <- df.all.it$total_length * df.all.it$total_length
  
  # Create index variables: ri = 1 if random; 0 else, mi = 1 if optimal; 0 else
  df.all.it$baseline <- factor(df.all.it$baseline, levels=c("Random", "Optimal", "Observed")) 
  df.all.it <- df.all.it %>% mutate(r = as.integer(baseline == "Random"), m = as.integer(baseline == "Optimal"), o = as.integer(baseline == "Observed"))
  
  
  # Factors index variables
  df.all.it$r <- factor(df.all.it$r) 
  df.all.it$o <- factor(df.all.it$o) 
  df.all.it$m <- factor(df.all.it$m) 
  
  # Unique ids for each sentence
  df.all.it <- df.all.it %>% mutate(sentence_uid = paste(channel, video_id, sentence_id, sep="_"))
  df.all.it$sentence_uid <- factor(df.all.it$sentence_uid)
  df.all.it$channel <- factor(df.all.it$channel)
  
  return(df.all.it)
}
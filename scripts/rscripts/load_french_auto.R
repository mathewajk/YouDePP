loadFrenchAuto <- function() {
  
  # AmixemAuto
  df.amixem.auto.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/fr/AmixemAuto/AmixemAuto_observed_dependencies.csv",
                                                      header=TRUE, sep=","))
  df.amixem.auto.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/fr/AmixemAuto/AmixemAuto_optimal_dependencies.csv",
                                                      header=TRUE, sep=","))
  df.amixem.auto.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/fr/AmixemAuto/AmixemAuto_random_dependencies.csv",
                                                      header=TRUE, sep=","))
  df.amixem.auto <- bind_rows(list("Observed"=df.amixem.auto.observed, "Optimal"=df.amixem.auto.optimal, 
                                      "Random"=df.amixem.auto.random),  .id = 'baseline')
  
  
  # CyprienAuto
  df.cyprien.auto.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/fr/CyprienAuto/CyprienAuto_observed_dependencies.csv",
                                                     header=TRUE, sep=","))
  df.cyprien.auto.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/fr/CyprienAuto/CyprienAuto_optimal_dependencies.csv",
                                                     header=TRUE, sep=","))
  df.cyprien.auto.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/fr/CyprienAuto/CyprienAuto_random_dependencies.csv",
                                                     header=TRUE, sep=","))
  df.cyprien.auto <- bind_rows(list("Observed"=df.cyprien.auto.observed, "Optimal"=df.cyprien.auto.optimal, 
                                     "Random"=df.cyprien.auto.random),  .id = 'baseline')
  
  
  # LeFatShowAuto
  df.fatshow.auto.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/fr/LeFatShowAuto/LeFatShowAuto_observed_dependencies.csv",
                                                       header=TRUE, sep=","))
  df.fatshow.auto.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/fr/LeFatShowAuto/LeFatShowAuto_optimal_dependencies.csv",
                                                       header=TRUE, sep=","))
  df.fatshow.auto.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/fr/LeFatShowAuto/LeFatShowAuto_random_dependencies.csv",
                                                       header=TRUE, sep=","))
  df.fatshow.auto <- bind_rows(list("Observed"=df.fatshow.auto.observed, "Optimal"=df.fatshow.auto.optimal, 
                                       "Random"=df.fatshow.auto.random),  .id = 'baseline')
  
  # NormanAuto
  df.norman.auto.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/fr/NormanAuto/NormanAuto_observed_dependencies.csv",
                                                  header=TRUE, sep=","))
  df.norman.auto.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/fr/NormanAuto/NormanAuto_optimal_dependencies.csv",
                                                  header=TRUE, sep=","))
  df.norman.auto.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/fr/NormanAuto/NormanAuto_random_dependencies.csv",
                                                  header=TRUE, sep=","))
  df.norman.auto <- bind_rows(list("Observed"=df.norman.auto.observed, "Optimal"=df.norman.auto.optimal, 
                                  "Random"=df.norman.auto.random),  .id = 'baseline')

  
  # SQUEEZIEAuto
  df.squeezie.auto.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/fr/SQUEEZIEAuto/SQUEEZIEAuto_observed_dependencies.csv",
                                                    header=TRUE, sep=","))
  df.squeezie.auto.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/fr/SQUEEZIEAuto/SQUEEZIEAuto_optimal_dependencies.csv",
                                                    header=TRUE, sep=","))
  df.squeezie.auto.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/fr/SQUEEZIEAuto/SQUEEZIEAuto_random_dependencies.csv",
                                                    header=TRUE, sep=","))
  df.squeezie.auto <- bind_rows(list("Observed"=df.squeezie.auto.observed, "Optimal"=df.squeezie.auto.optimal, 
                                    "Random"=df.squeezie.auto.random),  .id = 'baseline')
  
  # Bind data
  df.all.fr.auto <- bind_rows(list("AmixemAuto"=df.amixem.auto,
                                   "CyprienAutoAuto"=df.cyprien.auto,
                                   "LeFatShowAuto"=df.fatshow.auto,
                                   "NormanAuto"=df.norman.auto,
                                   "SQUEEZIEAuto"=df.squeezie.auto), .id = 'channel')
  
  # Calculate squared sentence length to match Futrell et al.: better predictor than raw length
  df.all.fr.auto$sent_len_sq   <- df.all.fr.auto$total_length * df.all.fr.auto$total_length
  
  # Create index variables: ri = 1 if random; 0 else, mi = 1 if optimal; 0 else
  df.all.fr.auto$baseline <- factor(df.all.fr.auto$baseline, levels=c("Random", "Optimal", "Observed")) 
  df.all.fr.auto <- df.all.fr.auto %>% mutate(r = as.integer(baseline == "Random"), m = as.integer(baseline == "Optimal"), o = as.integer(baseline == "Observed"))
  
  
  # Factors index variables
  df.all.fr.auto$r <- factor(df.all.fr.auto$r) 
  df.all.fr.auto$o <- factor(df.all.fr.auto$o) 
  df.all.fr.auto$m <- factor(df.all.fr.auto$m) 
  
  # Unique ids for each sentence
  df.all.fr.auto <- df.all.fr.auto %>% mutate(sentence_uid = paste(channel, video_id, sentence_id, sep="_"))
  df.all.fr.auto$sentence_uid <- factor(df.all.fr.auto$sentence_uid)
  df.all.fr.auto$channel <- factor(df.all.fr.auto$channel)
  
  return(df.all.fr.auto)
}
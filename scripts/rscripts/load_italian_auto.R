loadItalianAuto <- function() {
  
  # iPantellasAuto
  df.pantellas.auto.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/it/iPantellasAuto/iPantellasAuto_observed_dependencies.csv",
                                             header=TRUE, sep=","))
  df.pantellas.auto.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/it/iPantellasAuto/iPantellasAuto_optimal_dependencies.csv",
                                             header=TRUE, sep=","))
  df.pantellas.auto.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/it/iPantellasAuto/iPantellasAuto_random_dependencies.csv",
                                             header=TRUE, sep=","))
  df.pantellas.auto <- bind_rows(list("Observed"=df.pantellas.auto.observed, "Optimal"=df.pantellas.auto.optimal, 
                             "Random"=df.pantellas.auto.random),  .id = 'baseline')
  
  
  # MattBiseAuto
  df.mattbise.auto.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/it/MattBiseAuto/MattBiseAuto_observed_dependencies.csv",
                                                header=TRUE, sep=","))
  df.mattbise.auto.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/it/MattBiseAuto/MattBiseAuto_optimal_dependencies.csv",
                                                header=TRUE, sep=","))
  df.mattbise.auto.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/it/MattBiseAuto/MattBiseAuto_random_dependencies.csv",
                                                header=TRUE, sep=","))
  df.mattbise.auto <- bind_rows(list("Observed"=df.mattbise.auto.observed, "Optimal"=df.mattbise.auto.optimal, 
                                "Random"=df.mattbise.auto.random),  .id = 'baseline')
  
  
  # MeControteAuto
  df.mecontrote.auto.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/it/MeControteAuto/MeControteAuto_observed_dependencies.csv",
                                                header=TRUE, sep=","))
  df.mecontrote.auto.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/it/MeControteAuto/MeControteAuto_optimal_dependencies.csv",
                                                header=TRUE, sep=","))
  df.mecontrote.auto.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/it/MeControteAuto/MeControteAuto_random_dependencies.csv",
                                                header=TRUE, sep=","))
  df.mecontrote.auto <- bind_rows(list("Observed"=df.mecontrote.auto.observed, "Optimal"=df.mecontrote.auto.optimal, 
                                "Random"=df.mecontrote.auto.random),  .id = 'baseline')
  
  
  # SurryAuto
  df.surry.auto.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/it/SurryAuto/SurryAuto_observed_dependencies.csv",
                                                  header=TRUE, sep=","))
  df.surry.auto.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/it/SurryAuto/SurryAuto_optimal_dependencies.csv",
                                                  header=TRUE, sep=","))
  df.surry.auto.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/it/SurryAuto/SurryAuto_random_dependencies.csv",
                                                  header=TRUE, sep=","))
  df.surry.auto <- bind_rows(list("Observed"=df.surry.auto.observed, "Optimal"=df.surry.auto.optimal, 
                                  "Random"=df.surry.auto.random),  .id = 'baseline')
  
  # TheShowAuto
  df.theshow.auto.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/it/TheShowAuto/TheShowAuto_observed_dependencies.csv",
                                                  header=TRUE, sep=","))
  df.theshow.auto.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/it/TheShowAuto/TheShowAuto_optimal_dependencies.csv",
                                                  header=TRUE, sep=","))
  df.theshow.auto.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/it/TheShowAuto/TheShowAuto_random_dependencies.csv",
                                                  header=TRUE, sep=","))
  df.theshow.auto <- bind_rows(list("Observed"=df.theshow.auto.observed, "Optimal"=df.theshow.auto.optimal, 
                                  "Random"=df.theshow.auto.random),  .id = 'baseline')
  
  # Bind data
  df.all.it.auto <- bind_rows(list("iPantellasAuto"=df.pantellas.auto,
                              "MattBiseAutoAuto"=df.mattbise.auto,
                              "MeControteAuto"=df.mecontrote.auto,
                              "SurryAuto"=df.surry.auto,
                              "TheShowAuto"=df.theshow.auto), .id = 'channel')
  
  # Calculate squared sentence length to match Futrell et al.: better predictor than raw length
  df.all.it.auto$sent_len_sq   <- df.all.it.auto$total_length * df.all.it.auto$total_length
  
  # Create index variables: ri = 1 if random; 0 else, mi = 1 if optimal; 0 else
  df.all.it.auto$baseline <- factor(df.all.it.auto$baseline, levels=c("Random", "Optimal", "Observed")) 
  df.all.it.auto <- df.all.it.auto %>% mutate(r = as.integer(baseline == "Random"), m = as.integer(baseline == "Optimal"), o = as.integer(baseline == "Observed"))
  
  
  # Factors index variables
  df.all.it.auto$r <- factor(df.all.it.auto$r) 
  df.all.it.auto$o <- factor(df.all.it.auto$o) 
  df.all.it.auto$m <- factor(df.all.it.auto$m) 
  
  # Unique ids for each sentence
  df.all.it.auto <- df.all.it.auto %>% mutate(sentence_uid = paste(channel, video_id, sentence_id, sep="_"))
  df.all.it.auto$sentence_uid <- factor(df.all.it.auto$sentence_uid)
  df.all.it.auto$channel <- factor(df.all.it.auto$channel)
  
  return(df.all.it.auto)
}
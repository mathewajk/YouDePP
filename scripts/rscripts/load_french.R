loadFrench <- function() {
  
  # Other
  df.other.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/fr/Other/Other_observed_dependencies.csv",
                                             header=TRUE, sep=","))
  df.other.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/fr/Other/Other_optimal_dependencies.csv",
                                             header=TRUE, sep=","))
  df.other.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/fr/Other/Other_random_dependencies.csv",
                                             header=TRUE, sep=","))
  df.other <- bind_rows(list("Observed"=df.other.observed, "Optimal"=df.other.optimal, 
                             "Random"=df.other.random),  .id = 'baseline')
  
  # Cyprien
  df.cyprien.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/fr/Cyprien/Cyprien_observed_dependencies.csv",
                                                header=TRUE, sep=","))
  df.cyprien.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/fr/Cyprien/Cyprien_optimal_dependencies.csv",
                                                header=TRUE, sep=","))
  df.cyprien.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/fr/Cyprien/Cyprien_random_dependencies.csv",
                                                header=TRUE, sep=","))
  df.cyprien <- bind_rows(list("Observed"=df.cyprien.observed, "Optimal"=df.cyprien.optimal, 
                                "Random"=df.cyprien.random),  .id = 'baseline')
  
  # Joyca
  df.joyca.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/fr/Joyca/Joyca_observed_dependencies.csv",
                                                header=TRUE, sep=","))
  df.joyca.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/fr/Joyca/Joyca_optimal_dependencies.csv",
                                                header=TRUE, sep=","))
  df.joyca.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/fr/Joyca/Joyca_random_dependencies.csv",
                                                header=TRUE, sep=","))
  df.joyca <- bind_rows(list("Observed"=df.joyca.observed, "Optimal"=df.joyca.optimal, 
                                "Random"=df.joyca.random),  .id = 'baseline')
  
  
  # FabianOlicard
  df.fabianolicard.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/fr/FabianOlicard/FabianOlicard_observed_dependencies.csv",
                                             header=TRUE, sep=","))
  df.fabianolicard.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/fr/FabianOlicard/FabianOlicard_optimal_dependencies.csv",
                                             header=TRUE, sep=","))
  df.fabianolicard.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/fr/FabianOlicard/FabianOlicard_random_dependencies.csv",
                                             header=TRUE, sep=","))
  df.fabianolicard <- bind_rows(list("Observed"=df.fabianolicard.observed, "Optimal"=df.fabianolicard.optimal, 
                             "Random"=df.fabianolicard.random),  .id = 'baseline')
  
  
  # Bind data
  df.all.fr <- bind_rows(list("Other"=df.other,
                              "Cyprien"=df.cyprien,
                              "Joyca"=df.joyca,
                              "FabianOlicard"=df.fabianolicard), .id = 'channel')
  
  # Calculate squared sentence length to match Futrell et al.: better predictor than raw length
  df.all.fr$sent_len_sq   <- df.all.fr$total_length * df.all.fr$total_length
  
  # Create index variables: ri = 1 if random; 0 else, mi = 1 if optimal; 0 else
  df.all.fr$baseline <- factor(df.all.fr$baseline, levels=c("Random", "Optimal", "Observed")) 
  df.all.fr <- df.all.fr %>% mutate(r = as.integer(baseline == "Random"), m = as.integer(baseline == "Optimal"), o = as.integer(baseline == "Observed"))
  
  
  # Factors index variables
  df.all.fr$r <- factor(df.all.fr$r) 
  df.all.fr$o <- factor(df.all.fr$o) 
  df.all.fr$m <- factor(df.all.fr$m) 
  
  # Unique ids for each sentence
  df.all.fr <- df.all.fr %>% mutate(sentence_uid = paste(channel, video_id, sentence_id, sep="_"))
  df.all.fr$sentence_uid <- factor(df.all.fr$sentence_uid)
  df.all.fr$channel <- factor(df.all.fr$channel)
  
  return(df.all.fr)
}
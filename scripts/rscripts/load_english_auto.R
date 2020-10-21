loadEnglishAuto <- function() {
  
  # CollinsKeyAuto
  df.collins.auto.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/en/CollinsKeyAuto/CollinsKeyAuto_observed_dependencies.csv",
                                                   header=TRUE, sep=","))
  df.collins.auto.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/en/CollinsKeyAuto/CollinsKeyAuto_optimal_dependencies.csv",
                                                   header=TRUE, sep=","))
  df.collins.auto.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/en/CollinsKeyAuto/CollinsKeyAuto_random_dependencies.csv",
                                                   header=TRUE, sep=","))
  df.collins.auto <- bind_rows(list("Observed"=df.collins.auto.observed, "Optimal"=df.collins.auto.optimal, 
                                   "Random"=df.collins.auto.random),  .id = 'baseline')
  
  
  # JamesCharlesAuto
  df.james.auto.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/en/JamesCharlesAuto/JamesCharlesAuto_observed_dependencies.csv",
                                                    header=TRUE, sep=","))
  df.james.auto.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/en/JamesCharlesAuto/JamesCharlesAuto_optimal_dependencies.csv",
                                                    header=TRUE, sep=","))
  df.james.auto.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/en/JamesCharlesAuto/JamesCharlesAuto_random_dependencies.csv",
                                                    header=TRUE, sep=","))
  df.james.auto <- bind_rows(list("Observed"=df.james.auto.observed, "Optimal"=df.james.auto.optimal, 
                                    "Random"=df.james.auto.random),  .id = 'baseline')
  
  
  # NigahigaAuto
  df.nigahiga.auto.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/en/NigahigaAuto/NigahigaAuto_observed_dependencies.csv",
                                                    header=TRUE, sep=","))
  df.nigahiga.auto.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/en/NigahigaAuto/NigahigaAuto_optimal_dependencies.csv",
                                                    header=TRUE, sep=","))
  df.nigahiga.auto.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/en/NigahigaAuto/NigahigaAuto_random_dependencies.csv",
                                                    header=TRUE, sep=","))
  df.nigahiga.auto <- bind_rows(list("Observed"=df.nigahiga.auto.observed, "Optimal"=df.nigahiga.auto.optimal, 
                                    "Random"=df.nigahiga.auto.random),  .id = 'baseline')
  
  # LoganPaulAuto
  df.logan.auto.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/en/LoganPaulAuto/LoganPaulAuto_observed_dependencies.csv",
                                                   header=TRUE, sep=","))
  df.logan.auto.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/en/LoganPaulAuto/LoganPaulAuto_optimal_dependencies.csv",
                                                   header=TRUE, sep=","))
  df.logan.auto.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/en/LoganPaulAuto/LoganPaulAuto_random_dependencies.csv",
                                                   header=TRUE, sep=","))
  df.logan.auto <- bind_rows(list("Observed"=df.logan.auto.observed, "Optimal"=df.logan.auto.optimal, 
                                   "Random"=df.logan.auto.random),  .id = 'baseline')
  
  
  # PewDiePieAuto
  df.pewdiepie.auto.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/en/PewDiePieAuto/PewDiePieAuto_observed_dependencies.csv",
                                                     header=TRUE, sep=","))
  df.pewdiepie.auto.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/en/PewDiePieAuto/PewDiePieAuto_optimal_dependencies.csv",
                                                     header=TRUE, sep=","))
  df.pewdiepie.auto.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/en/PewDiePieAuto/PewDiePieAuto_random_dependencies.csv",
                                                     header=TRUE, sep=","))
  df.pewdiepie.auto <- bind_rows(list("Observed"=df.pewdiepie.auto.observed, "Optimal"=df.pewdiepie.auto.optimal, 
                                     "Random"=df.pewdiepie.auto.random),  .id = 'baseline')
  
  # Bind data
  df.all.en.auto <- bind_rows(list("CollinsKeyAuto"=df.collins.auto,
                                   "JamesCharlesAutoAuto"=df.james.auto,
                                   "NigahigaAuto"=df.nigahiga.auto,
                                   "LoganPaulAuto"=df.logan.auto,
                                   "PewDiePieAuto"=df.pewdiepie.auto), .id = 'channel')
  
  # Calculate squared sentence length to match Futrell et al.: better predictor than raw length
  df.all.en.auto$sent_len_sq   <- df.all.en.auto$total_length * df.all.en.auto$total_length
  
  # Create index variables: ri = 1 if random; 0 else, mi = 1 if optimal; 0 else
  df.all.en.auto$baseline <- factor(df.all.en.auto$baseline, levels=c("Random", "Optimal", "Observed")) 
  df.all.en.auto <- df.all.en.auto %>% mutate(r = as.integer(baseline == "Random"), m = as.integer(baseline == "Optimal"), o = as.integer(baseline == "Observed"))
  
  
  # Factors index variables
  df.all.en.auto$r <- factor(df.all.en.auto$r) 
  df.all.en.auto$o <- factor(df.all.en.auto$o) 
  df.all.en.auto$m <- factor(df.all.en.auto$m) 
  
  # Unique ids for each sentence
  df.all.en.auto <- df.all.en.auto %>% mutate(sentence_uid = paste(channel, video_id, sentence_id, sep="_"))
  df.all.en.auto$sentence_uid <- factor(df.all.en.auto$sentence_uid)
  df.all.en.auto$channel <- factor(df.all.en.auto$channel)
  
  return(df.all.en.auto)
}
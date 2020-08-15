loadRussian <- function() {
  
  # AdamThomasMoran
  df.adam.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ru/AdamThomasMoran/AdamThomasMoran_observed_dependencies.csv",
                                            header=TRUE, sep=","))
  df.adam.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ru/AdamThomasMoran/AdamThomasMoran_optimal_dependencies.csv",
                                            header=TRUE, sep=","))
  df.adam.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ru/AdamThomasMoran/AdamThomasMoran_random_dependencies.csv",
                                            header=TRUE, sep=","))
  df.adam <- bind_rows(list("Observed"=df.adam.observed, "Optimal"=df.adam.optimal, 
                           "Random"=df.adam.random),  .id = 'baseline')
  
  # NTV
  df.ntv.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ru/NTV/NTV_observed_dependencies.csv",
                                           header=TRUE, sep=","))
  df.ntv.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ru/NTV/NTV_optimal_dependencies.csv",
                                           header=TRUE, sep=","))
  df.ntv.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ru/NTV/NTV_random_dependencies.csv",
                                           header=TRUE, sep=","))
  df.ntv <- bind_rows(list("Observed"=df.ntv.observed, "Optimal"=df.ntv.optimal, 
                           "Random"=df.ntv.random),  .id = 'baseline')
  
  # TheBrainMaps
  df.TheBrianMaps.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ru/TheBrianMaps/TheBrianMaps_observed_dependencies.csv",
                                                    header=TRUE, sep=","))
  df.TheBrianMaps.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ru/TheBrianMaps/TheBrianMaps_optimal_dependencies.csv",
                                                    header=TRUE, sep=","))
  df.TheBrianMaps.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ru/TheBrianMaps/TheBrianMaps_random_dependencies.csv",
                                                    header=TRUE, sep=","))
  df.TheBrianMaps <- bind_rows(list("Observed"=df.TheBrianMaps.observed, "Optimal"=df.TheBrianMaps.optimal, 
                                    "Random"=df.TheBrianMaps.random),  .id = 'baseline')
  
  # ThisIsHorosho
  df.ThisIsHorosho.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ru/ThisIsHorosho/ThisIsHorosho_observed_dependencies.csv",
                                                     header=TRUE, sep=","))
  df.ThisIsHorosho.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ru/ThisIsHorosho/ThisIsHorosho_optimal_dependencies.csv",
                                                     header=TRUE, sep=","))
  df.ThisIsHorosho.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ru/ThisIsHorosho/ThisIsHorosho_random_dependencies.csv",
                                                     header=TRUE, sep=","))
  df.ThisIsHorosho <- bind_rows(list("Observed"=df.ThisIsHorosho.observed, "Optimal"=df.ThisIsHorosho.optimal, 
                                     "Random"=df.ThisIsHorosho.random),  .id = 'baseline')
  
  # Wylsacom
  df.Wylsacom.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ru/Wylsacom/Wylsacom_observed_dependencies.csv",
                                                header=TRUE, sep=","))
  df.Wylsacom.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ru/Wylsacom/Wylsacom_optimal_dependencies.csv",
                                                header=TRUE, sep=","))
  df.Wylsacom.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ru/Wylsacom/Wylsacom_random_dependencies.csv",
                                                header=TRUE, sep=","))
  df.Wylsacom <- bind_rows(list("Observed"=df.Wylsacom.observed, "Optimal"=df.Wylsacom.optimal, 
                                "Random"=df.Wylsacom.random),  .id = 'baseline')
  
  # AdvokatEgorov
  df.AdvokatEgorov.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ru/AdvokatEgorov/AdvokatEgorov_observed_dependencies.csv",
                                                header=TRUE, sep=","))
  df.AdvokatEgorov.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ru/AdvokatEgorov/AdvokatEgorov_optimal_dependencies.csv",
                                                header=TRUE, sep=","))
  df.AdvokatEgorov.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ru/AdvokatEgorov/AdvokatEgorov_random_dependencies.csv",
                                                header=TRUE, sep=","))
  df.AdvokatEgorov <- bind_rows(list("Observed"=df.AdvokatEgorov.observed, "Optimal"=df.AdvokatEgorov.optimal, 
                                "Random"=df.AdvokatEgorov.random),  .id = 'baseline')
  
  # Bind data
  df.all.ru <- bind_rows(list("AdamThomasMoran"=df.adam,
                              "NTV"=df.ntv,
                              "TheBrianMaps"=df.TheBrianMaps,
                              "ThisIsHorosho"=df.ThisIsHorosho,
                              "Wylsacom"=df.Wylsacom,
                              "Egorov"=df.AdvokatEgorov), .id = 'channel')
  
  # Calculate squared sentence length to match Futrell et al.: better predictor than raw length
  df.all.ru$sent_len_sq   <- df.all.ru$total_length * df.all.ru$total_length
  
  # Create index variables: ri = 1 if random; 0 else, mi = 1 if optimal; 0 else
  df.all.ru$baseline <- factor(df.all.ru$baseline, levels=c("Random", "Optimal", "Observed")) 
  df.all.ru <- df.all.ru %>% mutate(r = as.integer(baseline == "Random"), m = as.integer(baseline == "Optimal"), o = as.integer(baseline == "Observed"))
  
  
  # Factors index variables
  df.all.ru$r <- factor(df.all.ru$r) 
  df.all.ru$o <- factor(df.all.ru$o) 
  df.all.ru$m <- factor(df.all.ru$m) 
  
  # Unique ids for each sentence
  df.all.ru <- df.all.ru %>% mutate(sentence_uid = paste(channel, video_id, sentence_id, sep="_"))
  df.all.ru$sentence_uid <- factor(df.all.ru$sentence_uid)
  
  return(df.all.ru)
}
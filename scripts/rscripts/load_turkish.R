loadTurkish <- function() {
  
  # Sumeyra
  # df.sumeyra.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/Sumeyra/Sumeyra_observed_dependencies.csv",
  #                                           header=TRUE, sep=","))
  # df.sumeyra.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/Sumeyra/Sumeyra_optimal_dependencies.csv",
  #                                           header=TRUE, sep=","))
  # df.sumeyra.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/Sumeyra/Sumeyra_random_dependencies.csv",
  #                                           header=TRUE, sep=","))
  # df.sumeyra <- bind_rows(list("Observed"=df.sumeyra.observed, "Optimal"=df.sumeyra.optimal, 
  #                           "Random"=df.sumeyra.random),  .id = 'baseline')
  
  # SumeyraCorrected
  # df.sumeyra.corrected.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/manual/tr/Sumeyra/Sumeyra_observed_dependencies.csv",
  #                                              header=TRUE, sep=","))
  # df.sumeyra.corrected.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/manual/tr/Sumeyra/Sumeyra_optimal_dependencies.csv",
  #                                              header=TRUE, sep=","))
  # df.sumeyra.corrected.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/manual/tr/Sumeyra/Sumeyra_random_dependencies.csv",
  #                                              header=TRUE, sep=","))
  # df.sumeyra.corrected <- bind_rows(list("Observed"=df.sumeyra.corrected.observed, "Optimal"=df.sumeyra.corrected.optimal, 
  #                             "Random"=df.sumeyra.corrected.random),  .id = 'baseline')
  
  # SenCalKapimi
  # df.sencalkapimi.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/SenCalKapimi/SenCalKapimi_observed_dependencies.csv",
  #                                              header=TRUE, sep=","))
  # df.sencalkapimi.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/SenCalKapimi/SenCalKapimi_optimal_dependencies.csv",
  #                                              header=TRUE, sep=","))
  # df.sencalkapimi.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/SenCalKapimi/SenCalKapimi_random_dependencies.csv",
  #                                              header=TRUE, sep=","))
  # df.sencalkapimi <- bind_rows(list("Observed"=df.sencalkapimi.observed, "Optimal"=df.sencalkapimi.optimal, 
  #                             "Random"=df.sencalkapimi.random),  .id = 'baseline')
  
  # SenCalKapimi Corrected
  # df.sencalkapimi.corrected.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/manual/tr/SenCalKapimi/SenCalKapimi_observed_dependencies.csv",
  #                                                   header=TRUE, sep=","))
  # df.sencalkapimi.corrected.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/manual/tr/SenCalKapimi/SenCalKapimi_optimal_dependencies.csv",
  #                                                   header=TRUE, sep=","))
  # df.sencalkapimi.corrected.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/manual/tr/SenCalKapimi/SenCalKapimi_random_dependencies.csv",
  #                                                   header=TRUE, sep=","))
  # df.sencalkapimi.corrected <- bind_rows(list("Observed"=df.sencalkapimi.corrected.observed, "Optimal"=df.sencalkapimi.corrected.optimal, 
  #                                   "Random"=df.sencalkapimi.corrected.random),  .id = 'baseline')
  
  # DilaKnt
  df.dilakent.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/DilaKent/DilaKent_observed_dependencies.csv",
                                                    header=TRUE, sep=","))
  df.dilakent.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/DilaKent/DilaKent_optimal_dependencies.csv",
                                                    header=TRUE, sep=","))
  df.dilakent.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/DilaKent/DilaKent_random_dependencies.csv",
                                                    header=TRUE, sep=","))
  df.dilakent <- bind_rows(list("Observed"=df.dilakent.observed, "Optimal"=df.dilakent.optimal, 
                                    "Random"=df.dilakent.random),  .id = 'baseline')
  
  # EnesBatur
  # df.enesbatur.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/EnesBatur/EnesBatur_observed_dependencies.csv",
  #                                                   header=TRUE, sep=","))
  # df.enesbatur.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/EnesBatur/EnesBatur_optimal_dependencies.csv",
  #                                                   header=TRUE, sep=","))
  # df.enesbatur.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/EnesBatur/EnesBatur_random_dependencies.csv",
  #                                                   header=TRUE, sep=","))
  # df.enesbatur <- bind_rows(list("Observed"=df.enesbatur.observed, "Optimal"=df.enesbatur.optimal, 
  #                                  "Random"=df.enesbatur.random),  .id = 'baseline')
  
  # BizimHikayeDizi
  df.bizimhikayedizi.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/BizimHikayeDizi/BizimHikayeDizi_observed_dependencies.csv",
                                                 header=TRUE, sep=","))
  df.bizimhikayedizi.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/BizimHikayeDizi/BizimHikayeDizi_optimal_dependencies.csv",
                                                 header=TRUE, sep=","))
  df.bizimhikayedizi.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/BizimHikayeDizi/BizimHikayeDizi_random_dependencies.csv",
                                                 header=TRUE, sep=","))
  df.bizimhikayedizi <- bind_rows(list("Observed"=df.bizimhikayedizi.observed, "Optimal"=df.bizimhikayedizi.optimal, 
                                 "Random"=df.bizimhikayedizi.random),  .id = 'baseline')
  
  
  # DanlaBilic
  # df.danlabilic.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/DanlaBilic/DanlaBilic_observed_dependencies.csv",
  #                                                header=TRUE, sep=","))
  # df.danlabilic.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/DanlaBilic/DanlaBilic_optimal_dependencies.csv",
  #                                                header=TRUE, sep=","))
  # df.danlabilic.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/DanlaBilic/DanlaBilic_random_dependencies.csv",
  #                                                header=TRUE, sep=","))
  # df.danlabilic <- bind_rows(list("Observed"=df.danlabilic.observed, "Optimal"=df.danlabilic.optimal, 
  #                                "Random"=df.danlabilic.random),  .id = 'baseline')
  
  
  # DeliMiNe
  df.delimine.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/DeliMiNe/DeliMiNe_observed_dependencies.csv",
                                                 header=TRUE, sep=","))
  df.delimine.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/DeliMiNe/DeliMiNe_optimal_dependencies.csv",
                                                 header=TRUE, sep=","))
  df.delimine.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/DeliMiNe/DeliMiNe_random_dependencies.csv",
                                                 header=TRUE, sep=","))
  df.delimine <- bind_rows(list("Observed"=df.delimine.observed, "Optimal"=df.delimine.optimal, 
                                 "Random"=df.delimine.random),  .id = 'baseline')
  
  
  # OrkunIsitmak
  df.orkunisitmak.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/OrkunIsitmak/OrkunIsitmak_observed_dependencies.csv",
                                                 header=TRUE, sep=","))
  df.orkunisitmak.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/OrkunIsitmak/OrkunIsitmak_optimal_dependencies.csv",
                                                 header=TRUE, sep=","))
  df.orkunisitmak.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/OrkunIsitmak/OrkunIsitmak_random_dependencies.csv",
                                                 header=TRUE, sep=","))
  df.orkunisitmak <- bind_rows(list("Observed"=df.orkunisitmak.observed, "Optimal"=df.orkunisitmak.optimal, 
                                 "Random"=df.orkunisitmak.random),  .id = 'baseline')
  
  
  # Sesegel
  # df.sesegel.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/Sesegel/Sesegel_observed_dependencies.csv",
  #                                                header=TRUE, sep=","))
  # df.sesegel.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/Sesegel/Sesegel_optimal_dependencies.csv",
  #                                                header=TRUE, sep=","))
  # df.sesegel.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/Sesegel/Sesegel_random_dependencies.csv",
  #                                                header=TRUE, sep=","))
  # df.sesegel <- bind_rows(list("Observed"=df.sesegel.observed, "Optimal"=df.sesegel.optimal, 
  #                               "Random"=df.sesegel.random),  .id = 'baseline')
  
  
  # YasakElma
  df.yasakelma.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/YasakElma/YasakElma_observed_dependencies.csv",
                                               header=TRUE, sep=","))
  df.yasakelma.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/YasakElma/YasakElma_optimal_dependencies.csv",
                                               header=TRUE, sep=","))
  df.yasakelma.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/tr/YasakElma/YasakElma_random_dependencies.csv",
                                               header=TRUE, sep=","))
  df.yasakelma <- bind_rows(list("Observed"=df.yasakelma.observed, "Optimal"=df.yasakelma.optimal, 
                               "Random"=df.yasakelma.random),  .id = 'baseline')
  
  
  # Bind data
  df.all.tr <- bind_rows(list(#"Sumeyra"=df.sumeyra,
                              #"SumeyraCorrected"=df.sumeyra.corrected,
                              #"SenCalKapimi"=df.sencalkapimi,
                              #"SenCalKapimiCorrected"=df.sencalkapimi.corrected,
                              "DilaKent"=df.dilakent,
                              #"EnesBatur"=df.enesbatur,
                              "BizimHikayeDizi"=df.bizimhikayedizi,
                              #"DanlaBilic"=df.danlabilic,
                              "DeliMiNe"=df.delimine,
                              "OrkunIsitmak"=df.orkunisitmak,
                              #"Sesegel"=df.sesegel,
                              "YasakElma"=df.yasakelma), .id = 'channel')
  
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
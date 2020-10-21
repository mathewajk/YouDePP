loadEnglish <- function() {
  
  # CollinsKey
  df.collins.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/en/CollinsKey/CollinsKey_observed_dependencies.csv",
                                                    header=TRUE, sep=","))
  df.collins.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/en/CollinsKey/CollinsKey_optimal_dependencies.csv",
                                                    header=TRUE, sep=","))
  df.collins.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/en/CollinsKey/CollinsKey_random_dependencies.csv",
                                                    header=TRUE, sep=","))
  df.collins <- bind_rows(list("Observed"=df.collins.observed, "Optimal"=df.collins.optimal, 
                                    "Random"=df.collins.random),  .id = 'baseline')
  
  
  # JamesCharles
  df.james.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/en/JamesCharles/JamesCharles_observed_dependencies.csv",
                                                  header=TRUE, sep=","))
  df.james.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/en/JamesCharles/JamesCharles_optimal_dependencies.csv",
                                                  header=TRUE, sep=","))
  df.james.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/en/JamesCharles/JamesCharles_random_dependencies.csv",
                                                  header=TRUE, sep=","))
  df.james <- bind_rows(list("Observed"=df.james.observed, "Optimal"=df.james.optimal, 
                                  "Random"=df.james.random),  .id = 'baseline')
  
  
  # Nigahiga
  df.nigahiga.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/en/Nigahiga/Nigahiga_observed_dependencies.csv",
                                                     header=TRUE, sep=","))
  df.nigahiga.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/en/Nigahiga/Nigahiga_optimal_dependencies.csv",
                                                     header=TRUE, sep=","))
  df.nigahiga.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/en/Nigahiga/Nigahiga_random_dependencies.csv",
                                                     header=TRUE, sep=","))
  df.nigahiga <- bind_rows(list("Observed"=df.nigahiga.observed, "Optimal"=df.nigahiga.optimal, 
                                     "Random"=df.nigahiga.random),  .id = 'baseline')
  
  # LoganPaul
  df.logan.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/en/LoganPaul/LoganPaul_observed_dependencies.csv",
                                                  header=TRUE, sep=","))
  df.logan.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/en/LoganPaul/LoganPaul_optimal_dependencies.csv",
                                                  header=TRUE, sep=","))
  df.logan.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/en/LoganPaul/LoganPaul_random_dependencies.csv",
                                                  header=TRUE, sep=","))
  df.logan <- bind_rows(list("Observed"=df.logan.observed, "Optimal"=df.logan.optimal, 
                                  "Random"=df.logan.random),  .id = 'baseline')
  
  # Bind data
  df.all.en <- bind_rows(list("CollinsKey"=df.collins,
                                   "JamesCharles"=df.james,
                                   "Nigahiga"=df.nigahiga,
                                   "LoganPaul"=df.logan), .id = 'channel')
  
  # Calculate squared sentence length to match Futrell et al.: better predictor than raw length
  df.all.en$sent_len_sq   <- df.all.en$total_length * df.all.en$total_length
  
  # Create index variables: ri = 1 if random; 0 else, mi = 1 if optimal; 0 else
  df.all.en$baseline <- factor(df.all.en$baseline, levels=c("Random", "Optimal", "Observed")) 
  df.all.en <- df.all.en %>% mutate(r = as.integer(baseline == "Random"), m = as.integer(baseline == "Optimal"), o = as.integer(baseline == "Observed"))
  
  
  # Factors index variables
  df.all.en$r <- factor(df.all.en$r) 
  df.all.en$o <- factor(df.all.en$o) 
  df.all.en$m <- factor(df.all.en$m) 
  
  # Unique ids for each sentence
  df.all.en <- df.all.en %>% mutate(sentence_uid = paste(channel, video_id, sentence_id, sep="_"))
  df.all.en$sentence_uid <- factor(df.all.en$sentence_uid)
  df.all.en$channel <- factor(df.all.en$channel)
  
  return(df.all.en)
}
loadKorean <- function() {
  
  # Baekhyun
  # df.baekhyun.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ko/Baekhyun/Baekhyun_observed_dependencies.csv",
  #                                              header=TRUE, sep=","))
  # df.baekhyun.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ko/Baekhyun/Baekhyun_optimal_dependencies.csv",
  #                                              header=TRUE, sep=","))
  # df.baekhyun.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ko/Baekhyun/Baekhyun_random_dependencies.csv",
  #                                              header=TRUE, sep=","))
  # df.baekhyun <- bind_rows(list("Observed"=df.baekhyun.observed, "Optimal"=df.baekhyun.optimal, 
  #                             "Random"=df.baekhyun.random),  .id = 'baseline')
  
  # Ddeongkaeddeong
  # df.ddeongkaeddeong.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ko/Ddeongkaeddeong/Ddeongkaeddeong_observed_dependencies.csv",
  #                                               header=TRUE, sep=","))
  # df.ddeongkaeddeong.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ko/Ddeongkaeddeong/Ddeongkaeddeong_optimal_dependencies.csv",
  #                                               header=TRUE, sep=","))
  # df.ddeongkaeddeong.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ko/Ddeongkaeddeong/Ddeongkaeddeong_random_dependencies.csv",
  #                                               header=TRUE, sep=","))
  # df.ddeongkaeddeong <- bind_rows(list("Observed"=df.ddeongkaeddeong.observed, "Optimal"=df.ddeongkaeddeong.optimal, 
  #                              "Random"=df.ddeongkaeddeong.random),  .id = 'baseline')
  
  # EatwithBoki
  df.eatwithboki.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ko/EatwithBoki/EatwithBoki_observed_dependencies.csv",
                                                header=TRUE, sep=","))
  df.eatwithboki.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ko/EatwithBoki/EatwithBoki_optimal_dependencies.csv",
                                                header=TRUE, sep=","))
  df.eatwithboki.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ko/EatwithBoki/EatwithBoki_random_dependencies.csv",
                                                header=TRUE, sep=","))
  df.eatwithboki <- bind_rows(list("Observed"=df.eatwithboki.observed, "Optimal"=df.eatwithboki.optimal, 
                                "Random"=df.eatwithboki.random),  .id = 'baseline')
  
  # G-NI
  df.gni.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ko/G-NI/G-NI_observed_dependencies.csv",
                                                header=TRUE, sep=","))
  df.gni.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ko/G-NI/G-NI_optimal_dependencies.csv",
                                                header=TRUE, sep=","))
  df.gni.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ko/G-NI/G-NI_random_dependencies.csv",
                                                header=TRUE, sep=","))
  df.gni <- bind_rows(list("Observed"=df.gni.observed, "Optimal"=df.gni.optimal, 
                                "Random"=df.gni.random),  .id = 'baseline')
  
  # HongyuASMR
  df.hongyu.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ko/HongyuASMR/HongyuASMR_observed_dependencies.csv",
                                                header=TRUE, sep=","))
  df.hongyu.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ko/HongyuASMR/HongyuASMR_optimal_dependencies.csv",
                                                header=TRUE, sep=","))
  df.hongyu.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ko/HongyuASMR/HongyuASMR_random_dependencies.csv",
                                                header=TRUE, sep=","))
  df.hongyu <- bind_rows(list("Observed"=df.hongyu.observed, "Optimal"=df.hongyu.optimal, 
                                "Random"=df.hongyu.random),  .id = 'baseline')
  
  # JaneASMR
  df.jane.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ko/JaneASMR/JaneASMR_observed_dependencies.csv",
                                                header=TRUE, sep=","))
  df.jane.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ko/JaneASMR/JaneASMR_optimal_dependencies.csv",
                                                header=TRUE, sep=","))
  df.jane.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ko/JaneASMR/JaneASMR_random_dependencies.csv",
                                                header=TRUE, sep=","))
  df.jane <- bind_rows(list("Observed"=df.jane.observed, "Optimal"=df.jane.optimal, 
                                "Random"=df.jane.random),  .id = 'baseline')
  
  # SULGI
  df.sulgi.observed <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ko/SULGI/SULGI_observed_dependencies.csv",
                                                header=TRUE, sep=","))
  df.sulgi.optimal  <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ko/SULGI/SULGI_optimal_dependencies.csv",
                                                header=TRUE, sep=","))
  df.sulgi.random   <- data.frame(read.table("~/Documents/research/git-projects/YouDePP/corpus/dependency_counts/auto/ko/SULGI/SULGI_random_dependencies.csv",
                                                header=TRUE, sep=","))
  df.sulgi <- bind_rows(list("Observed"=df.sulgi.observed, "Optimal"=df.sulgi.optimal, 
                                "Random"=df.sulgi.random),  .id = 'baseline')
  
  
  # Bind data
  df.all.ko <- bind_rows(list(#"Baekhyun"=df.baekhyun,
                              #"Ddeongkaeddeong"=df.ddeongkaeddeong,
                              "EatwithBoki"=df.eatwithboki,
                              "G-NI"=df.gni,
                              "HongyuASMR"=df.hongyu,
                              "JaneASMR"=df.jane,
                              "SULGI"=df.sulgi), .id = 'channel')
  
  # Calculate squared sentence length to match Futrell et al.: better predictor than raw length
  df.all.ko$sent_len_sq   <- df.all.ko$total_length * df.all.ko$total_length
  
  # Create index variables: ri = 1 if random; 0 else, mi = 1 if optimal; 0 else
  df.all.ko$baseline <- factor(df.all.ko$baseline, levels=c("Random", "Optimal", "Observed")) 
  df.all.ko <- df.all.ko %>% mutate(r = as.integer(baseline == "Random"), m = as.integer(baseline == "Optimal"), o = as.integer(baseline == "Observed"))
  
  
  # Factors index variables
  df.all.ko$r <- factor(df.all.ko$r) 
  df.all.ko$o <- factor(df.all.ko$o) 
  df.all.ko$m <- factor(df.all.ko$m) 
  
  # Unique ids for each sentence
  df.all.ko <- df.all.ko %>% mutate(sentence_uid = paste(channel, video_id, sentence_id, sep="_"))
  df.all.ko$sentence_uid <- factor(df.all.ko$sentence_uid)
  df.all.ko$channel <- factor(df.all.ko$channel)
  
  return(df.all.ko)
}
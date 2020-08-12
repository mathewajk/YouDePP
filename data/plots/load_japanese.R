loadJapanese <- function() {

  # Yuuka Kinoshita
  df.yuuka.observed <- data.frame(read.table("../../corpus/dependencies/ja/YukaKinoshita/YukaKinoshita_observed_dependencies.csv",
                                             header=TRUE, sep=","))
  df.yuuka.optimal  <- data.frame(read.table("../../corpus/dependencies/ja/YukaKinoshita/YukaKinoshita_optimal_dependencies.csv",
                                             header=TRUE, sep=","))
  df.yuuka.random   <- data.frame(read.table("../../corpus/dependencies/ja/YukaKinoshita/YukaKinoshita_random_dependencies.csv",
                                             header=TRUE, sep=","))
  df.yuuka <- bind_rows(list("Observed"=df.yuuka.observed, "Optimal"=df.yuuka.optimal, 
                             "Random"=df.yuuka.random),  .id = 'baseline')

  # Hikakin
  df.hikakin.observed <- data.frame(read.table("../../corpus/dependencies/ja/HikakinTV/HikakinTV_observed_dependencies.csv", 
                                               header=TRUE, sep=","))
  df.hikakin.optimal  <- data.frame(read.table("../../corpus/dependencies/ja/HikakinTV/HikakinTV_optimal_dependencies.csv",  
                                               header=TRUE, sep=","))
  df.hikakin.random   <- data.frame(read.table("../../corpus/dependencies/ja/HikakinTV/HikakinTV_random_dependencies.csv",   
                                               header=TRUE, sep=","))
  df.hikakin <- bind_rows(list("Observed"=df.hikakin.observed, "Optimal"=df.hikakin.optimal, 
                               "Random"=df.hikakin.random),  .id = 'baseline')

 # Fischer's (uncorrected)
  df.fischers.observed <- data.frame(read.table("../../corpus/dependencies/auto_subs/ja/Fischers/Fischers_observed_dependencies.csv",
                                                header=TRUE, sep=","))
  df.fischers.optimal  <- data.frame(read.table("../../corpus/dependencies/auto_subs/ja/Fischers/Fischers_optimal_dependencies.csv",
                                                header=TRUE, sep=","))
  df.fischers.random   <- data.frame(read.table("../../corpus/dependencies/auto_subs/ja/Fischers/Fischers_random_dependencies.csv", 
                                                header=TRUE, sep=","))
  df.fischers <- bind_rows(list("Observed"=df.fischers.observed, "Optimal"=df.fischers.optimal,
                                "Random"=df.fischers.random),  .id = 'baseline')
  
  # Fischer's (corrected)
  df.fischers.hc.observed <- data.frame(read.table("../../corpus/dependencies/hand_corrected_subs/ja/Fischers/Fischers_observed_dependencies.csv",
                                                   header=TRUE, sep=","))
  df.fischers.hc.optimal  <- data.frame(read.table("../../corpus/dependencies/hand_corrected_subs/ja/Fischers/Fischers_optimal_dependencies.csv",
                                                   header=TRUE, sep=","))
  df.fischers.hc.random   <- data.frame(read.table("../../corpus/dependencies/hand_corrected_subs/ja/Fischers/Fischers_random_dependencies.csv", 
                                                   header=TRUE, sep=","))
  df.fischers.hc <- bind_rows(list("Observed"=df.fischers.hc.observed, "Optimal"=df.fischers.hc.optimal,
                                   "Random"=df.fischers.hc.random),  .id = 'baseline')
  
  # Hajime Shachoo
  df.hajime.observed <- data.frame(read.table("../../corpus/dependencies/ja/HajimeShachoo/HajimeShachoo_observed_dependencies.csv",
                                              header=TRUE, sep=","))
  df.hajime.optimal  <- data.frame(read.table("../../corpus/dependencies/ja/HajimeShachoo/HajimeShachoo_optimal_dependencies.csv",
                                              header=TRUE, sep=","))
  df.hajime.random   <- data.frame(read.table("../../corpus/dependencies/ja/HajimeShachoo/HajimeShachoo_random_dependencies.csv",
                                              header=TRUE, sep=","))
  df.hajime <- bind_rows(list("Observed"=df.hajime.observed, "Optimal"=df.hajime.optimal, 
                              "Random"=df.hajime.random),  .id = 'baseline')

  # Tokai on Air
  df.tokai.observed <- data.frame(read.table("../../corpus/dependencies/ja/TokaiOnAir/TokaiOnAir_observed_dependencies.csv",
                                             header=TRUE, sep=","))
  df.tokai.optimal  <- data.frame(read.table("../../corpus/dependencies/ja/TokaiOnAir/TokaiOnAir_optimal_dependencies.csv",
                                             header=TRUE, sep=","))
  df.tokai.random   <- data.frame(read.table("../../corpus/dependencies/ja/TokaiOnAir/TokaiOnAir_random_dependencies.csv", 
                                             header=TRUE, sep=","))
  df.tokai <- bind_rows(list("Observed"=df.tokai.observed, "Optimal"=df.tokai.optimal, 
                             "Random"=df.tokai.random),  .id = 'baseline')
  
  # Bind data
  df.all.jp <- bind_rows(list("1"=df.yuuka, 
                              "2a"=df.fischers,
                              "2b"=df.fischers.hc,
                              "3"=df.hajime, 
                              "4"=df.hikakin,
                              "5"=df.tokai), .id = 'channel')
  
  return(df.all.jp)
}
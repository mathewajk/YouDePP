library(dplyr)

clean_stats <- function(df, dep_cutoff, include_auto=T, remove_outliers=T, outlier_cutoff=1.5) {
  
  # Remove unnecesary columns and auto-subbed data
  df.temp <- df %>% select(-starts_with("verb"), -starts_with("subject"), -starts_with("object")) %>%
    filter(num_deps <= dep_cutoff)
  
  # Remove automatically-generated subtitles
  if(!include_auto) {
    df.temp <- df.temp %>% filter(!grepl("Auto", corpus) )
  }
  
  # Rename columns for easier pivoting
  df.temp <- df.temp %>%
    rename(numDeps_all=num_deps, headFinality_all=head_finality, 
           totalDL_all=total_dl, averageDL_all=average_dl, averageDLSL_all=average_dl_sl, 
           numDeps_noFunc=num_deps_no_func, headFinality_noFunc=head_finality_no_func, 
           totalDL_noFunc=total_dl_no_func, averageDL_noFunc=average_dl_no_func,
           averageDLSL_noFunc=average_dl_sl_no_func)
  
  if(remove_outliers) {
    
    # Find ids of non-outliers
    df.ids.no_outliers <- df.temp  %>%
      filter(baseline=="observed") %>% 
      group_by(language, corpus, numDeps_all) %>%
      mutate(Q1_all = quantile(totalDL_all, .25), Q3_all=quantile(totalDL_all, .75), IQR_all=IQR(totalDL_all)) %>%
      ungroup() %>%
      group_by(language, corpus, numDeps_noFunc) %>%
      mutate(Q1_noFunc = quantile(totalDL_noFunc, .25), Q3_noFunc=quantile(totalDL_noFunc, .75), IQR_noFunc=IQR(totalDL_noFunc)) %>%
      ungroup() %>%
      filter(!(totalDL_all > (Q3_all + outlier_cutoff*IQR_all) & totalDL_all < (Q1_all - outlier_cutoff*IQR_all)) & 
             !(totalDL_noFunc > (Q3_noFunc + outlier_cutoff*IQR_noFunc) & totalDL_noFunc < (Q1_noFunc - outlier_cutoff*IQR_noFunc))) %>% 
      select(id)
    
    # Remove outliers
    df.temp <- df.temp %>% filter(id %in% df.ids.no_outliers$id)
  }
  
  # Clean up data with outliers removed
  return(df.temp %>% 
           mutate(is_sov=ifelse(order=="sov", 1, 0),
                  is_osv=ifelse(order=="osv", 1, 0),
                  is_vso=ifelse(order=="vso", 1, 0),
                  is_vos=ifelse(order=="vos", 1, 0),
                  is_svo=ifelse(order=="svo", 1, 0),
                  is_ovs=ifelse(order=="ovs", 1, 0),
                  is_sv=ifelse(order=="sv", 1, 0),
                  is_vs=ifelse(order=="vs", 1, 0),
                  is_ov=ifelse(order=="ov", 1, 0),
                  is_vo=ifelse(order=="vo", 1, 0)) %>%
           mutate(is_transitive=ifelse(grepl("^[sov][sov][sov]$", order), 1, 0), 
                  is_intransitive=ifelse(grepl("^[sv][sv]$", order), 1, 0), 
                  is_subjdrop=ifelse(grepl("^[ov][ov]$", order), 1, 0), 
                  is_vonly=ifelse(order=="v", 1, 0)) %>%
           mutate(language=factor(language, levels=c("fr", "ru", "it", "en", "ja", "tr", "ko")),
                  baseline=factor(baseline, levels=c("random", "observed", "optimal")))
  )
}

Sys.setlocale(category = "LC_CTYPE", locale = "C")

load(file='~/Documents/research/git-projects/YouDePP/data/youdepp_stats.Rda')
load(file='~/Documents/research/git-projects/YouDePP/data/ud_stats.Rda')

df.youdepp.stats.unfiltered <- df.youdepp.stats
df.ud.stats.unfiltered      <- df.ud.stats

df.youdepp.stats.unfiltered %>% filter(baseline=="observed") %>% group_by(baseline, language) %>% summarize(count=n()) %>% ungroup()
df.ud.stats.unfiltered %>% filter(baseline=="observed") %>% group_by(baseline, language) %>% summarize(count=n()) %>% ungroup()

# Outliers are removed from the YouTube data on the assumption that they don't represent features of the language, in contrast to UD.
df.youdepp.stats <- df.youdepp.stats.unfiltered %>% clean_stats(15, remove_outliers=T, include_auto=T) %>% 
  filter_all(all_vars(!is.na(.) & !is.infinite(.) & !is.nan(.)))
df.ud.stats     <- df.ud.stats.unfiltered %>% clean_stats(15, remove_outliers=F, include_auto=F) %>% 
  filter_all(all_vars(!is.na(.) & !is.infinite(.) & !is.nan(.)))

range(df.youdepp.stats$numDeps_all)
range(df.ud.stats$numDeps_all)

df.youdepp.stats %>% filter(baseline=="observed") %>% group_by(baseline, language) %>% summarize(count=n()) %>% ungroup()
df.ud.stats %>% filter(baseline=="observed") %>% group_by(baseline, language) %>% summarize(count=n()) %>% ungroup()

save(df.youdepp.stats, file="~/Documents/research/git-projects/YouDePP/data/youdepp_stats_clean.Rda")
save(df.ud.stats, file="~/Documents/research/git-projects/YouDePP/data/ud_stats_clean.Rda")
library(dplyr)
library(sport)
library(ggplot2)
library(pbapply)

files <- list.files("./auc_results_6_models_400_params/")

# load files content to a list
results <- lapply(files, function(file){
  auc_results <- read.csv(paste0('./auc_results_6_models_400_params/', file))
  elo_results <- read.csv(paste0('./elo_results_6_models_400_params/elo_', file))
  elo_results[["class"]] <- strsplit(as.character(elo_results[["model"]]), "_") %>%
    lapply(first) %>%
    unlist()
  elo_results <- elo_results %>%
    select(-"X")
  
  auc_results <- auc_results %>%
    mutate(model_param = paste(auc_results$model, auc_results$param_index, sep = '_')) %>%
    select(-"X", -"X.1", -"time", -"param_index", -"acc")
  
  list(elo_results = elo_results, auc_results = auc_results)
  
})
names(results) <- files
# Each element of tha list results corresponds to one data set and contains elo and AUC of models.


calculate_sport_ranking <- function(sport_fun, name, auc_results){
  elo_sport <- sport_fun(formula = auc | row_index ~ player(model_param), data = auc_results)
  elo_sport_results <- data.frame(model = names(elo_sport$final_r), elo = elo_sport$final_r)
  elo_sport_results[["class"]] <- strsplit(as.character(elo_sport_results[["model"]]), "_") %>%
    lapply(first) %>%
    unlist()
  elo_sport_results[["method"]] <- name
  elo_sport_results
}
# Add sport rankings - can be loaded below
results_final <- pblapply(results, function(results_dataset){
  auc_results <- results_dataset[["auc_results"]] %>%
    group_by(row_index) %>%
    mutate(auc = rank(-auc, ties.method = "random")) %>%
    arrange(row_index)
  
  elo_sport_glicko <- calculate_sport_ranking(sport::glicko_run, "glicko", auc_results)
  elo_sport_glicko2 <- calculate_sport_ranking(sport::glicko2_run, "glicko2", auc_results)
  elo_sport_bbt <- calculate_sport_ranking(sport::bbt_run, "bbt", auc_results)
  elo_sport_dbl <- calculate_sport_ranking(sport::dbl_run, "dbl", auc_results)
  
  elo_results <- results_dataset[["elo_results"]]
  colnames(elo_results)[2] <- "elo"
  elo_results[["method"]] <- "elo"
  
  rbind(elo_results, elo_sport_glicko, elo_sport_glicko2, elo_sport_bbt, elo_sport_dbl)
})

# save(results_final, file = "./data./results_final")
load("./data./results_final")

plots <- lapply(files, function(dataset_name){
  elo_final <- results_final[[dataset_name]]
  elo_final$model <- gsub("model_param=", "", elo_final$model)
  elo_final[["class"]] <- strsplit(as.character(elo_final[["model"]]), "_") %>%
    lapply(first) %>%
    unlist()
  
  ggplot(elo_final, aes(x=factor(class), y = elo, fill= factor(class))) +
    geom_boxplot() + 
    coord_flip() +
    facet_wrap(~method, scales = "free", ncol = 1) +
    theme(legend.position = "bottom") + 
    ggtitle(dataset_name)
  
})


plots[[1]]
plots[[2]]
plots[[34]]





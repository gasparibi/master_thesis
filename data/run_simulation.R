###############################################################################
# File: run_simulation.R
#
# Purpose:
#   Runs the crossover simulation defined in simulate_crossover.R and exports
#   the resulting balanced and unbalanced datasets to CSV and RDS formats.
#
# Inputs:
#   - data/simulate_crossover.R
#
# Outputs:
#   - data/sim_data.rds
#   - data/sim_data.csv
#   - data/sim_data_un.rds
#   - data/sim_data_un.csv
#
# Usage:
#   Run from the project root:
#     source("data/run_simulation.R")
#
# Author: Bianca Gasparini
###############################################################################

library(dplyr) 
library(purrr)  
library(tidyr)    

source("data/simulate_crossover.R")

res <- simulate_crossover()

saveRDS(res$balanced, "data/sim_data.rds")
write.csv(res$balanced, "data/sim_data.csv", row.names = FALSE)

saveRDS(res$unbalanced, "data/sim_data_un.rds")
write.csv(res$unbalanced, "data/sim_data_un.csv", row.names = FALSE)

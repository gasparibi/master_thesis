###############################################################################
# File: run_simulation_cr.R
#
# Purpose:
#   Runs the crossover simulation defined in simulate_crossover.R and exports
#   the resulting balanced and unbalanced datasets to CSV and RDS formats.
#
# Inputs:
#   - data/crossover/simulate_crossover.R
#
# Outputs:
#   - data/crossover/example/sim_cr.rds
#   - data/crossover/example/sim_cr.csv
#   - data/crossover/example/sim_cr_un.rds
#   - data/crossover/example/sim_cr_un.csv
#
# Author: Bianca Gasparini
###############################################################################

source("data/crossover/simulate_crossover.R")

res <- simulate_crossover()

saveRDS(res$balanced, "data/crossover/example/sim_cr.rds")
write.csv(res$balanced, "data/crossover/example/sim_cr.csv", row.names = FALSE)

saveRDS(res$unbalanced, "data/crossover/example/sim_cr_un.rds")
write.csv(res$unbalanced, "data/crossover/example/sim_cr_un.csv", row.names = FALSE)

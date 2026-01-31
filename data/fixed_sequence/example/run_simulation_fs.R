###############################################################################
# File: run_simulation_fs.R
#
# Purpose:
#   Runs the fixed-sequence simulation defined in simulate_fixed_sequence.R and 
#   exports the resulting balanced and unbalanced datasets to CSV and RDS formats.
#
# Inputs:
#   - data/crossover/simulate_crossover.R
#
# Outputs:
#   - data/fixed_sequence/example/sim_fs.rds
#   - data/fixed_sequence/example/sim_fs.csv
#   - data/fixed_sequence/example/sim_fs_un.rds
#   - data/fixed_sequence/example/sim_fs_un.csv
#
# Author: Bianca Gasparini
###############################################################################

source("data/fixed_sequence/simulate_fixed_sequence.R")

res <- simulate_fixed_sequence()

saveRDS(res$balanced, "data/fixed_sequence/example/sim_fs.rds")
write.csv(res$balanced, "data/fixed_sequence/example/sim_fs.csv", row.names = FALSE)

saveRDS(res$unbalanced, "data/fixed_sequence/example/sim_fs_un.rds")
write.csv(res$unbalanced, "data/fixed_sequence/example/sim_fs_un.csv", row.names = FALSE)

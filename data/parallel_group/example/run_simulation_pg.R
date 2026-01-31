###############################################################################
# File: run_simulation_pg.R
#
# Purpose:
#   Runs the parallel-group simulation defined in simulate_parallel.R and exports
#   the resulting dataset to CSV and RDS formats.
#
# Inputs:
#   - data/parallel_group/simulate_parallel.R
#
# Outputs:
#   - data/parallel_group/example/sim_pg.rds
#   - data/parallel_group/example/sim_pg.csv
#
# Author: Bianca Gasparini
###############################################################################

source("data/parallel_group/simulate_parallel.R")

res <- simulate_parallel()

saveRDS(res, "data/parallel_group/example/sim_pg.rds")
write.csv(res, "data/parallel_group/example/sim_pg.csv", row.names = FALSE)

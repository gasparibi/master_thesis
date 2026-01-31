###############################################################################
# File: run_simulation_cr.R
#
# Purpose:
#   Runs the 2x2 crossover PK data simulation defined in
#   simulate_crossover.R, saves the balanced and unbalanced datasets,
#   and performs model validation using fixed- and mixed-effects
#   models for all PK parameters.
#
# Inputs:
#   - data/crossover/simulate_crossover.R
#   - data/crossover/validate_crossover.R
#
# Outputs:
#   - data/crossover/example/sim_cr.rds
#   - data/crossover/example/sim_cr.csv
#   - data/crossover/example/sim_cr_un.rds
#   - data/crossover/example/sim_cr_un.csv
#
# Author: Bianca Gasparini
###############################################################################

# Simulation
source("data/crossover/simulate_crossover.R")

res <- simulate_crossover()

saveRDS(res$balanced, "data/crossover/example/sim_cr.rds")
write.csv(res$balanced, "data/crossover/example/sim_cr.csv", row.names = FALSE)

saveRDS(res$unbalanced, "data/crossover/example/sim_cr_un.rds")
write.csv(res$unbalanced, "data/crossover/example/sim_cr_un.csv", row.names = FALSE)

# Validation
source("data/crossover/validate_crossover.R")

validate_all_cr(res, dataset = "balanced", model_type = "fixed")
validate_all_cr(res, dataset = "balanced", model_type = "mixed")
validate_all_cr(res, dataset = "unbalanced", model_type = "fixed")
validate_all_cr(res, dataset = "unbalanced", model_type = "mixed")

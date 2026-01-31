###############################################################################
# File: run_simulation_fs.R
#
# Purpose:
#   Runs the fixed-sequence simulation defined in simulate_fs.R and 
#   exports the resulting balanced and unbalanced datasets to CSV and RDS formats.
#
# Inputs:
#   - data/fixed_sequence/simulate_fs.R
#
# Outputs:
#   - data/fixed_sequence/example/sim_fs.rds
#   - data/fixed_sequence/example/sim_fs.csv
#   - data/fixed_sequence/example/sim_fs_un.rds
#   - data/fixed_sequence/example/sim_fs_un.csv
#
# Author: Bianca Gasparini
###############################################################################

# Simulation
source("data/fixed_sequence/simulate_fs.R")

res <- simulate_fixed_sequence()

saveRDS(res$balanced, "data/fixed_sequence/example/sim_fs.rds")
write.csv(res$balanced, "data/fixed_sequence/example/sim_fs.csv", row.names = FALSE)

saveRDS(res$unbalanced, "data/fixed_sequence/example/sim_fs_un.rds")
write.csv(res$unbalanced, "data/fixed_sequence/example/sim_fs_un.csv", row.names = FALSE)

# Validation
source("data/fixed_sequence/validate_fs.R")

validate_all_fs(res, dataset = "balanced", model_type = "fixed")
validate_all_fs(res, dataset = "balanced", model_type = "mixed")
validate_all_fs(res, dataset = "unbalanced", model_type = "fixed")
validate_all_fs(res, dataset = "unbalanced", model_type = "mixed")

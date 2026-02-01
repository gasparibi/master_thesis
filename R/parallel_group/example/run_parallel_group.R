###############################################################################
# File: run_parallel_group.R
#
# Purpose:
#   Runs the parallel-group bioavailability analysis workflow using
#   simulated PK data. The script:
#
#     - Loads a simulated parallel-group dataset
#     - Fits GLS models by PK parameter
#     - Back-transforms model results to the original scale
#     - Builds summary tables for reporting
#     - Produces formatted GT tables and forest plots
#
# Inputs:
#   - data/parallel_group/example/sim_pg.rds
#   - R/parallel_group/model_fit_pg.R
#   - R/common/back_transform.R
#   - R/common/table_builders.R
#   - R/common/reporting.R
#
# Outputs:
#   - Formatted GT table objects
#   - Forest plot objects
#
# Author: Bianca Gasparini
###############################################################################

## Load the data
sim_data_pg <- readRDS("data/parallel_group/example/sim_pg.rds")

## Fit the model
source("R/parallel_group/model_fit_pg.R")

model_pg <- run_models_pg(sim_data_pg)

## Back-transform the results
source("R/common/back_transform.R")

## Build the tables
source("R/common/table_builders.R")

endpoint_map <- tibble(
  Parameter = c("AUC0_tz", "Cmax", "AUCINF_pred"),
  Group     = c("Primary endpoints", "Primary endpoints", "Secondary endpoint")
)

final_table_pg <- build_final_table(models = model_pg, data = sim_data_pg, endpoint_map = endpoint_map)

## Reporting tables and plots
source("R/common/reporting.R")

# Formatted table
gt_table_pg <- make_gt_table(final_table_pg, design = "parallel")

# Forest plots
forest_pg <- make_forest_plot(final_table = final_table_pg, design = "parallel")

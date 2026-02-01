###############################################################################
# File: run_fixed_sequence.R
#
# Purpose:
#   Executes the full analysis pipeline for a fixed-sequence PK study
#   using previously simulated datasets. The script:
#
#     - Loads balanced and unbalanced fixed-sequence simulation outputs
#     - Fits fixed- and mixed-effects models for each PK parameter
#     - Back-transforms model estimates to the original scale
#     - Builds summary tables for primary and secondary endpoints
#     - Produces formatted reporting tables and forest plots
#
# Inputs:
#   - data/fixed_sequence/example/sim_cr.rds
#   - data/fixed_sequence/example/sim_cr_un.rds
#
# Sourced scripts:
#   - R/fixed_sequence/model_fit_fs.R
#   - R/common/back_transform.R
#   - R/common/table_builders.R
#   - R/common/reporting.R
#
# Outputs:
#   - In-memory objects:
#       * model_fe / model_me
#       * model_fe_un / model_me_un
#       * final_table_fe / final_table_me
#       * final_table_fe_un / final_table_me_un
#       * gt tables for reporting
#       * forest plots for reporting
#
# Author: Bianca Gasparini
###############################################################################

## Load the data
sim_data <- readRDS("data/fixed_sequence/example/sim_fs.rds")
sim_data_un <- readRDS("data/fixed_sequence/example/sim_fs_un.rds")

## Fit the model
source("R/fixed_sequence/model_fit_fs.R")

models_fe <- run_models_fs(sim_data, "fixed")
models_me <- run_models_fs(sim_data, "mixed")

models_fe_un <- run_models_fs(sim_data_un, "fixed")
models_me_un <- run_models_fs(sim_data_un, "mixed")

## Back-transform the results
source("R/common/back_transform.R")

## Build the tables
source("R/common/table_builders.R")

endpoint_map <- tibble(
  Parameter = c("AUC0_tz", "Cmax", "AUCINF_pred"),
  Group     = c("Primary endpoints", "Primary endpoints", "Secondary endpoint")
)

final_table_fe <- build_final_table(models = models_fe, data = sim_data, endpoint_map = endpoint_map)
final_table_me <- build_final_table(models = models_me, data = sim_data, endpoint_map = endpoint_map)

final_table_fe_un <- build_final_table(models = models_fe_un, data = sim_data_un, endpoint_map = endpoint_map)
final_table_me_un <- build_final_table(models = models_me_un, data = sim_data_un, endpoint_map = endpoint_map)

## Reporting tables and plots
source("R/common/reporting.R")

# Formatted table
gt_table_fe <- make_gt_table(final_table_fe, design = "fixed_sequence", model_type = "fixed", dataset_type = "balanced")
gt_table_me <- make_gt_table(final_table_me, design = "fixed_sequence", model_type = "mixed", dataset_type = "balanced")

gt_table_fe_un  <- make_gt_table(final_table_fe_un, design = "fixed_sequence", model_type = "fixed", dataset_type = "unbalanced")
gt_table_me_un  <- make_gt_table(final_table_me_un, design = "fixed_sequence", model_type = "mixed", dataset_type = "unbalanced")

# Forest plots
forest_fe <- make_forest_plot(final_table_fe, design = "fixed_sequence", model_type = "fixed", dataset_type = "balanced")
forest_me <- make_forest_plot(final_table_me, design = "fixed_sequence", model_type = "mixed", dataset_type = "balanced")

forest_fe_un <- make_forest_plot(final_table_fe_un, design = "fixed_sequence", model_type = "fixed", dataset_type = "unbalanced")
forest_me_un <- make_forest_plot(final_table_me_un, design = "fixed_sequence", model_type = "mixed", dataset_type = "unbalanced")

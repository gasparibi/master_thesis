###############################################################################
# File: run_crossover.R
#
# Purpose:
#   Executes the full analysis pipeline for a 2x2 crossover PK study
#   using previously simulated datasets. The script:
#
#     - Loads balanced and unbalanced crossover simulation outputs
#     - Fits fixed- and mixed-effects models for each PK parameter
#     - Back-transforms model estimates to the original scale
#     - Builds summary tables for primary and secondary endpoints
#     - Produces formatted reporting tables and forest plots
#
# Inputs:
#   - data/crossover/example/sim_cr.rds
#   - data/crossover/example/sim_cr_un.rds
#
# Sourced scripts:
#   - R/crossover/model_fit_cr.R
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
# Used by:
#   - quarto/crossover_case_study.qmd
#
# Author: Bianca Gasparini
###############################################################################

## Load the data
sim_cr <- readRDS("data/crossover/example/sim_cr.rds")
sim_cr_un <- readRDS("data/crossover/example/sim_cr_un.rds")

## Fit the model
source("R/crossover/model_fit_cr.R")

models_fe <- run_models_cr(sim_cr, "fixed")
models_me <- run_models_cr(sim_cr, "mixed")

models_fe_un <- run_models_cr(sim_cr_un, "fixed")
models_me_un <- run_models_cr(sim_cr_un, "mixed")

## Back-transform the results
source("R/common/back_transform.R")

## Build the tables
source("R/common/table_builders.R")

endpoint_map <- tibble(
  Parameter = c("AUC0_tz", "Cmax", "AUCINF_pred"),
  Group     = c("Primary endpoints", "Primary endpoints", "Secondary endpoint")
)

final_table_fe <- build_final_table(models_fe, sim_cr, endpoint_map)
final_table_me <- build_final_table(models_me, sim_cr, endpoint_map)

final_table_fe_un <- build_final_table(models_fe_un, sim_cr_un, endpoint_map)
final_table_me_un <- build_final_table(models_me_un, sim_cr_un, endpoint_map)

## Reporting tables and plots
source("R/common/reporting.R")

# Formatted table
gt_table_fe <- make_gt_table(final_table_fe, "crossover", "fixed", "balanced")
gt_table_me <- make_gt_table(final_table_me, "crossover", "mixed", "balanced")

gt_table_fe_un <- make_gt_table(final_table_fe_un, "crossover", "fixed", "unbalanced")
gt_table_me_un <- make_gt_table(final_table_me_un, "crossover", "mixed", "unbalanced")

# Forest plots
forest_fe <- make_forest_plot(final_table_fe, "crossover", "fixed", "balanced")
forest_me <- make_forest_plot(final_table_me, "crossover", "mixed", "balanced")

forest_fe_un <- make_forest_plot(final_table_fe_un, "crossover", "fixed", "unbalanced")
forest_me_un <- make_forest_plot(final_table_me_un, "crossover", "mixed", "unbalanced")

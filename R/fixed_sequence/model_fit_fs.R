###############################################################################
# File: model_fit_fs.R
#
# Purpose:
#   Defines functions to fit relative bioavailability models for Phase 1
#   fixed-sequence studies under fixed- or mixed-effects ANOVA formulations.
#
# Contents:
#   - fit_rel_bioav_fs(): fits a model for one PK parameter and computes
#       treatment LSMeans and 90% CI.
#   - run_models_fs(): applies fit_rel_bioav_fs() across PK parameters.
#
# Intended for:
#   - 2x2 fixed-sequence designs
#   - Comparison of R vs SAS implementations
#
# Dependencies:
#   emmeans, lme4, purrr
#
# Author: Bianca Gasparini
###############################################################################

library(emmeans)
library(lme4)
library(purrr)

#' Fit relative bioavailability model
#'
#' Fits either a fixed- or mixed-effects ANOVA model on log-transformed PK
#' data and computes treatment LSMeans, geometric mean ratio, and 90% CI.
#'
#' @param data A data frame containing a single PK parameter.
#' @param model_type Character: "fixed" or "mixed".
#'
#' @return A list with:
#'   \describe{
#'     \item{emmeans_summary}{LSMeans by treatment}
#'     \item{contrast_summary}{Treatment contrast with CI}
#'     \item{sigma}{Residual SD from the fitted model}
#'   }

# Fit the model
fit_rel_bioav_fs <- function(data, model_type = c("fixed", "mixed")) {
  model_type <- match.arg(model_type)
  
  # Define formula based on type
  formula <- if(model_type == "fixed") {
    logPK ~ Subject + Treatment
  } else {
    logPK ~ (1|Subject) + Treatment
  }
  
  model <- if(model_type == "fixed") lm(formula, data) else lmer(formula, data)
  
  fit  <- emmeans(model, ~ Treatment, level = 0.9)
  diff <- contrast(fit, method = "revpairwise")
  
  list(
    emmeans_summary  = summary(fit),
    contrast_summary = summary(diff, infer = TRUE),
    sigma            = sigma(model) 
  )
}

#' Fit models across PK parameters
#'
#' Splits a dataset by PK parameter and fits relative bioavailability models
#' for each parameter using the selected model type.
#'
#' @param data Full PK dataset with multiple parameters.
#' @param model_type "fixed" or "mixed".
#'
#' @return Named list of model results by PK parameter.

# Run the models
run_models_fs <- function(data, model_type) {
  split(data, data$Parameter) |>
    map(fit_rel_bioav_fs, model_type = model_type)
}
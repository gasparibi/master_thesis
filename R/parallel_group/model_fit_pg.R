###############################################################################
# File: model_fit_pg.R
#
# Purpose:
#   Defines functions to fit relative bioavailability models for Phase 1
#   parallel-group studies under fixed- or mixed-effects ANOVA formulations.
#
# Contents:
#   - fit_rel_bioav_pg(): fits a model for one PK parameter and computes
#       treatment LSMeans and 90% CI.
#   - run_models_pg(): applies fit_rel_bioav_pg() across PK parameters.
#
# Intended for:
#   - 2-treatment parallel-group designs
#   - Comparison of R vs SAS implementations
#
# Dependencies:
#   dplyr, emmeans, nlme, purrr
#
# Author: Bianca Gasparini
###############################################################################

library(dplyr)
library(emmeans)
library(nlme)
library(purrr)

#' Fit relative bioavailability model for a parallel-group study
#'
#' This function fits a generalized least squares (GLS) model to log-transformed
#' PK data from a 2-treatment parallel-group study. It computes estimated
#' marginal means (LSMeans) for each treatment, pairwise contrasts, and a
#' pooled residual standard deviation across treatments.
#'
#' @param data A data frame containing PK data for a single parameter. Must
#'   contain the columns:
#'   \describe{
#'     \item{logPK}{log-transformed pharmacokinetic measurement}
#'     \item{Treatment}{factor indicating treatment group ("R" or "T")}
#'     \item{Subject}{unique subject identifier}
#'   }
#'
#' @return A list with the following components:
#'   \describe{
#'     \item{emmeans_summary}{Estimated marginal means for each treatment}
#'     \item{contrast_summary}{Pairwise treatment contrast with 90% confidence interval}
#'     \item{sigma}{Pooled residual standard deviation across treatment groups}
#'   }

fit_rel_bioav_pg <- function(data) {
  
  # Fit the model
  model <- gls(
    logPK ~ Treatment,
    data = data,
    weights = varIdent(form = ~ 1 | Treatment)
  )
  
  # Estimated marginal means and contrasts
  fit  <- emmeans(model, ~ Treatment, level = 0.9, data = data) 
  diff <- contrast(fit, method = "revpairwise")
  
  # Calculate sigma values
  sigma_vals <- sigma(model) * c(T = 1, coef(model$modelStruct$varStruct, unconstrained = FALSE))
  
  sigma_R <- sigma_vals["R"]
  sigma_T <- sigma_vals["T"]
  
  # Sample sizes per group
  n_per_trt <- data %>%
    group_by(Treatment) %>%
    summarise(n = n_distinct(Subject), .groups = "drop")
  
  n_R <- n_per_trt$n[n_per_trt$Treatment == "R"]
  n_T <- n_per_trt$n[n_per_trt$Treatment == "T"]
  
  # Pooled SD
  sigma_pooled <- sqrt(
    ((n_R - 1) * sigma_R^2 + (n_T - 1) * sigma_T^2) / (n_R + n_T - 2)
  )
  
  # Return results as a list
  list(
    emmeans_summary  = summary(fit),
    contrast_summary = summary(diff, infer = TRUE),
    sigma = sigma_pooled
  )
}

#' Fit relative bioavailability models for all PK parameters
#'
#' This function splits a parallel-group PK dataset by parameter and applies
#' `fit_rel_bioav_pg()` to each subset. Returns a named list of results for
#' each parameter.
#'
#' @param data A data frame containing multiple PK parameters, with columns:
#'   \describe{
#'     \item{Parameter}{name of the PK parameter}
#'     \item{logPK}{log-transformed PK measurement}
#'     \item{Treatment}{factor with levels "R" and "T"}
#'     \item{Subject}{unique subject identifier}
#'   }
#'
#' @return A named list of results, one element per PK parameter. Each element
#'   is a list returned by `fit_rel_bioav_pg()`.

# Run the models
run_models_pg <- function(data) {
  split(data, data$Parameter) |>
    map(fit_rel_bioav_pg)
}
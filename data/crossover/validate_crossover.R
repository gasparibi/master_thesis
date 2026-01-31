###############################################################################
# File: validate_crossover.R
#
# Purpose:
#   Provides functions to validate fixed- and mixed-effects models for
#   2x2 crossover PK study data using residual diagnostics.
#
#   Includes:
#     - validate_crossover_model(): fits a model for a single PK parameter
#       and generates Q-Q and residual-vs-fitted plots.
#     - validate_all_cr(): applies model validation across all PK
#       parameters in a simulated dataset.
#
# Used by:
#   - quarto/crossover_case_study.qmd
#   - data/crossover/example/run_simulation_cr.R
#
# Author: Bianca Gasparini
###############################################################################

library(dplyr)
library(lme4)
library(purrr)

# ---------------------------------------------------------------------------
# Single-parameter validation
# ---------------------------------------------------------------------------

#' Validate crossover model assumptions
#'
#' Fits either a fixed- or mixed-effects model to crossover PK data
#' and produces standard residual diagnostics.
#'
#' @param df Data frame containing crossover PK data.
#' @param param_name Character string naming the PK parameter being analysed.
#' @param model_type Either "fixed" or "mixed".
#'
#' @return Invisibly returns the fitted model object.

validate_crossover_model <- function(
    df,
    param_name,
    model_type = c("fixed", "mixed")
) {
  
  model_type <- match.arg(model_type)
  
  message(
    paste0(
      toTitleCase(model_type),
      " effects model: ",
      param_name
    )
  )
  
  # ---- Model formulas ----
  if (model_type == "fixed") {
    
    formula <- logPK ~ Sequence + Subject:Sequence + Period + Treatment
    
    model <- lm(formula, data = df)
    
    model_label <- "Fixed"
    
  } else {
    
    formula <- logPK ~ Sequence + Period + Treatment +
      (1 | Subject:Sequence)
    
    model <- lmer(formula, data = df)
    
    model_label <- "Mixed"
  }
  
  # ---- Residual diagnostics ----
  resid_vals  <- resid(model)
  fitted_vals <- fitted(model)
  
  qqnorm(
    resid_vals,
    main = paste("Q-Q Plot -", param_name, "(", model_label, ")")
  )
  qqline(resid_vals, col = "red")
  
  plot(
    fitted_vals,
    resid_vals,
    main = paste("Residuals vs Fitted -", param_name, "(", model_label, ")"),
    xlab = "Fitted values",
    ylab = "Residuals",
    pch  = 19,
    col  = "gray"
  )
  abline(h = 0, col = "red")
  
  invisible(model)
}

# ---------------------------------------------------------------------------
# Apply validation across all PK parameters
# ---------------------------------------------------------------------------

#' Validate crossover models for all PK parameters
#'
#' Applies fixed- or mixed-effects model diagnostics across all PK
#' parameters in a simulated 2x2 crossover dataset.
#'
#' The function subsets the selected dataset (balanced or unbalanced),
#' fits the requested model type for each PK parameter using
#' \code{validate_crossover_model()}, and produces residual diagnostic
#' plots.
#'
#' @param sim_list Output list from \code{simulate_crossover()}.
#' @param dataset Which dataset to use: "balanced" or "unbalanced".
#' @param model_type Model type: "fixed" or "mixed".
#'
#' @return Invisibly returns a named list of fitted model objects,
#'   one per PK parameter.
#'
#' @examples
#' \dontrun{
#' validate_all_cr(res, dataset = "balanced", model_type = "mixed")
#' validate_all_cr(res, dataset = "unbalanced", model_type = "fixed")
#' }

validate_all_cr <- function(
    sim_list,
    dataset    = c("balanced", "unbalanced"),
    model_type = c("fixed", "mixed")
) {
  
  dataset    <- match.arg(dataset)
  model_type <- match.arg(model_type)
  
  df_all <- sim_list[[dataset]]
  
  params <- df_all %>%
    distinct(Parameter) %>%
    pull(Parameter)
  
  fits <- map(
    params,
    ~ {
      df_p <- filter(df_all, Parameter == .x)
      validate_crossover_model(df_p, .x, model_type = model_type)
    }
  )
  
  names(fits) <- params
  
  invisible(fits)
}

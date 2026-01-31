###############################################################################
# File: validate_parallel.R
#
# Purpose:
#   Provides functions to validate GLS models for parallel-group
#   PK study data by assessing normality of standardized residuals.
#
#   Includes:
#     - validate_parallel_model(): fits a GLS model with heteroscedastic
#       residual structure by treatment group and produces Q-Q plots.
#     - validate_all_pg(): applies validation across all PK parameters
#       in a parallel-group dataset.
#
# Author: Bianca Gasparini
###############################################################################

library(dplyr)
library(purrr)
library(nlme)

# ---------------------------------------------------------------------------
# Single-parameter validation
# ---------------------------------------------------------------------------

#' Validate parallel-group model residual normality
#'
#' Fits a GLS model with treatment-specific residual variances and
#' produces a Q-Q plot of standardized residuals to assess normality.
#'
#' @param df Data frame containing parallel-group PK data
#'   for a single PK parameter.
#' @param param_name Character string naming the PK parameter.
#'
#' @return Invisibly returns the fitted \code{gls} model object.
#'
#' @examples
#' \dontrun{
#' validate_parallel_model(df_auc, "AUC0_tz")
#' }

validate_parallel_model <- function(
    df,
    param_name
) {
  
  message("Parallel-group model: ", param_name)
  
  # ---- Fit GLS model ----
  model <- gls(
    logPK ~ Treatment,
    data = df,
    weights = varIdent(form = ~ 1 | Treatment)
  )
  
  # ---- Normalized residuals ----
  resid_vals <- resid(model, type = "normalized")
  
  qqnorm(
    resid_vals,
    main = paste("Q-Q Plot -", param_name)
  )
  qqline(resid_vals, col = "red")
  
  invisible(model)
}

# ---------------------------------------------------------------------------
# Apply validation across all PK parameters
# ---------------------------------------------------------------------------

#' Validate parallel-group models for all PK parameters
#'
#' Applies residual normality diagnostics across all PK parameters
#' in a parallel-group dataset.
#'
#' @param sim_data Output data frame from \code{simulate_parallel()}.
#'
#' @return Invisibly returns a named list of fitted GLS model objects,
#'   one per PK parameter.
#'
#' @examples
#' \dontrun{
#' validate_all_pg(sim_pg)
#' }

validate_all_pg <- function(sim_data) {
  
  params <- sim_data %>%
    distinct(Parameter) %>%
    pull(Parameter)
  
  fits <- map(
    params,
    ~ {
      df_p <- filter(sim_data, Parameter == .x)
      validate_parallel_model(df_p, .x)
    }
  )
  
  names(fits) <- params
  
  invisible(fits)
}

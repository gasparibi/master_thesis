###############################################################################
# File: back_transform.R
#
# Purpose:
#   Provides utilities to back-transform log-scale model results from
#   relative bioavailability analyses into the original PK scale.
#
# Description:
#   Converts treatment LSMeans and contrasts obtained from emmeans into:
#     - geometric means,
#     - geometric mean ratios with 90% confidence intervals,
#     - geometric coefficient of variation (GCV) derived from the residual
#       variance.
#
# Dependencies:
#   dplyr
#
# Author: Bianca Gasparini
###############################################################################

library(dplyr)

#' Back-transform relative bioavailability results
#'
#' Converts log-scale model outputs from \code{fit_rel_bioav()} into
#' geometric means, geometric standard errors, geometric mean ratios, 
#' confidence intervals, and geometric coefficient of variation (GCV).
#'
#' @param result_list A list produced by \code{fit_rel_bioav()}, containing:
#'   \describe{
#'     \item{emmeans_summary}{Data frame of LSMeans on the log scale.}
#'     \item{contrast_summary}{Treatment contrast estimates and confidence
#'       limits on the log scale.}
#'     \item{sigma}{Residual standard deviation from the fitted model.}
#'   }
#'
#' @return A list with:
#'   \describe{
#'     \item{adjusted}{Data frame with geometric means and standard errors 
#'       by treatment.}
#'     \item{ratio}{Data frame with geometric mean ratio and 90\% CI.}
#'     \item{variab}{Geometric coefficient of variation (GCV).}
#'   }
#'
#' @details
#' The geometric coefficient of variation is computed as:
#' \deqn{GCV = \sqrt{\exp(\sigma^2) - 1}}
#'
#' where \eqn{\sigma^2} is the residual variance from the fitted model.
#'
#' @seealso \code{\link{fit_rel_bioav}}, \code{\link{run_models}}

# Back-transform the results
back_transform <- function(result_list) {
  
  adj <- result_list[["emmeans_summary"]] |>
    mutate(
      adj_gmean = exp(emmean),
      adj_gse   = exp(SE)
    )
  
  rat <- result_list[["contrast_summary"]] |>
    mutate(
      ratio = exp(estimate),
      gse   = exp(SE),
      lower = exp(lower.CL),
      upper = exp(upper.CL)
    )
  
  resid_var <- result_list[["sigma"]]^2
  
  gcv <- sqrt(exp(resid_var) - 1)
  
  list(
    adjusted = adj,
    ratio    = rat,
    variab   = gcv
  )
}
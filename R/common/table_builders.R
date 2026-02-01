###############################################################################
# File: table_builders.R
#
# Purpose:
#   Defines helper functions to assemble formatted analysis tables from
#   relative bioavailability model outputs.
#
# Description:
#   These functions combine:
#     - model results produced by fit_rel_bioav(),
#     - back-transformed estimates from back_transform(),
#     - subject counts per treatment,
#   into a single data frame ready for reporting or rendering with gt.
#
# Contents:
#   - prepare_table(): creates a parameter-level results block.
#   - build_final_table(): combines results across endpoints.
#
# Intended for:
#   - Phase 1 crossover bioavailability studies
#   - SAS-to-R comparison workflows
#   - Quarto-based regulatory-style reporting
#
# Dependencies:
#   dplyr, purrr, tibble
#
# Author: Bianca Gasparini
###############################################################################

library(dplyr)
library(purrr)
library(tibble)

#' Prepare formatted results block for one PK parameter
#'
#' Combines model outputs, back-transformed estimates, and subject counts
#' into a table section suitable for reporting.
#'
#' @param model_results A list returned by \code{fit_rel_bioav()} for a single
#'   PK parameter.
#' @param indata Original analysis dataset containing Subject, Treatment,
#'   and Parameter.
#' @param parameter Character string naming the PK parameter.
#' @param group Character label used to group endpoints in the final table
#'   (e.g., "Primary endpoints").
#'
#' @return A tibble containing:
#'   \itemize{
#'     \item adjusted geometric means and gSE by treatment,
#'     \item geometric mean ratio (T/R) with 90\% CI,
#'     \item geometric coefficient of variation (gCV),
#'     \item grouping labels for table rendering.
#'   }
#'
#' @seealso \code{\link{back_transform}}, \code{\link{build_final_table}}

prepare_table <- function(model_results, indata, parameter, group) {
  
  back_transformed <- back_transform(model_results)
  
  adj <- back_transformed$adjusted
  rat <- back_transformed$ratio
  gcv <- back_transformed$variab
  
  n_per_param <- indata %>%
    filter(Parameter == parameter) %>%
    group_by(Treatment) %>%
    summarise(n = n_distinct(Subject), .groups = "drop")
  
  adj <- adj %>%
    left_join(n_per_param, by = "Treatment") %>%
    select(Treatment, n, adj_gmean, adj_gse) %>%
    mutate(Group = group)
  
  adj <- adj %>%
    mutate(
      n = as.character(n),
      adj_gmean = sprintf("%.2f", adj_gmean),
      adj_gse   = sprintf("%.2f", adj_gse),
      ratio = ifelse(row_number() == 1, sprintf("%.2f", rat$ratio * 100), ""),
      gse   = ifelse(row_number() == 1, sprintf("%.2f", rat$gse), ""),
      lower = ifelse(row_number() == 1, sprintf("%.2f", rat$lower * 100), ""),
      upper = ifelse(row_number() == 1, sprintf("%.2f", rat$upper * 100), ""),
      gCV   = ifelse(row_number() == 1, sprintf("%.1f", gcv * 100), "")
    )
  
  parameter_row <- tibble(
    Treatment = parameter,
    n = "",
    adj_gmean = "",
    adj_gse = "",
    ratio = "",
    gse = "",
    lower = "",
    upper = "",
    gCV = "",
    Group = group
  )
  
  bind_rows(parameter_row, adj)
}

#' Assemble final analysis table across PK endpoints
#'
#' Iterates over PK parameters and constructs a complete reporting table
#' using \code{prepare_table()}.
#'
#' @param models Named list of model results indexed by PK parameter.
#' @param data Original analysis dataset.
#' @param endpoint_map Tibble defining PK parameters and their reporting
#'   groups (e.g., primary vs secondary endpoints).
#'
#' @return A tibble containing the full analysis table ready for rendering
#'   with \code{gt}.
#'
#' @seealso \code{\link{prepare_table}}, \code{\link{make_gt_table}}

build_final_table <- function(models, data, endpoint_map) {
  
  params <- endpoint_map$Parameter
  
  map(params,\(p) {
    grp <- endpoint_map |> filter(Parameter == p) |> pull(Group)
    
    prepare_table(models[[p]], data, p, grp)}) |>
    bind_rows()
}
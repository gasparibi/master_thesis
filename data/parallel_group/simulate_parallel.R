###############################################################################
# File: simulate_parallel.R
#
# Purpose:
#   Defines a function to simulate PK data for a parallel-group Phase 1 study
#   under log-normal assumptions.
#
# Author: Bianca Gasparini
###############################################################################

library(dplyr)
library(tidyr)

#' Simulate parallel-group PK study
#'
#' Generates log-PK data for multiple PK parameters under a
#' parallel-group design.
#'
#' @param n_subjects Number of subjects (total).
#' @param seed Random seed.
#' @param allocation Treatment allocation ratio (default 1:1).
#'
#' @return A tibble with simulated PK data.
#'
#' @examples
#' sim <- simulate_parallel()

simulate_parallel <- function(
    n_subjects = 80,
    seed       = 646997,
    allocation = c(R = 1, T = 1)
) {
  
  set.seed(seed)
  
  # ---- Subjects ----
  subjects <- seq_len(n_subjects)
  
  # ---- Randomize treatment ----
  alloc_vec <- rep(names(allocation), times = allocation)
  treatments <- sample(
    rep(alloc_vec, length.out = n_subjects)
  )
  
  # ---- Mean (log-scale) parameters ----
  mu_table <- tribble(
    ~Treatment, ~Parameter,       ~mu,
    "T",        "AUC0_tz",        6.146901,
    "T",        "AUCINF_pred",    6.173306,
    "T",        "Cmax",           5.098963,
    "R",        "AUC0_tz",        6.248518,
    "R",        "AUCINF_pred",    6.265877,
    "R",        "Cmax",           5.088447
  )
  
  # ---- Single SD per parameter ----
  sd_table <- tribble(
    ~Parameter,       ~sd,
    "AUC0_tz",             0.33,
    "AUCINF_pred",         0.33,
    "Cmax",                0.25
  )
  
  # ---- Combine parameters ----
  log_params <- mu_table %>%
    left_join(sd_table, by = "Parameter")
  
  param_levels <- unique(log_params$Parameter)
  
  # ---- Design ----
  design <- tibble(
    Subject   = factor(subjects),
    Treatment = factor(treatments, levels = c("R", "T"))
  )
  
  # ---- Simulate PK ----
  sim_data <- design %>%
    crossing(Parameter = param_levels) %>%
    left_join(log_params,
                     by = c("Treatment", "Parameter")) %>%
    mutate(
      residual = rnorm(n(), 0, sd),
      logPK    = mu + residual,
      PK       = exp(logPK)
    ) %>%
    select(
      Subject,
      Treatment,
      Parameter,
      logPK,
      PK
    ) %>%
    arrange(Parameter, Subject)
  
  sim_data
}

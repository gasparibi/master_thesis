###############################################################################
# File: simulate_crossover.R
#
# Purpose:
#   Defines a function to simulate PK data for a 2x2 crossover Phase 1 study
#   under log-normal assumptions with between- and within-subject variability.
#
# Contents:
#   - simulate_crossover(): returns balanced and unbalanced datasets.
#
# Used by:
#   - quarto/crossover_case_study.qmd
#   - data/run_simulation.R
#
# Outputs:
#   None directly; datasets returned as R objects.
#
# Author: Bianca Gasparini
###############################################################################

library(dplyr)
library(purrr)
library(tidyr)

#' Simulate 2x2 crossover PK study
#'
#' Generates log-PK data for multiple PK parameters under a
#' 2x2 crossover design with between- and within-subject variability.
#'
#' @param n_subjects Number of subjects.
#' @param seed Random seed.
#' @param drop_subjects Subjects to drop in unbalanced version.
#' @param drop_period Period removed.
#'
#' @return A list with:
#'   \describe{
#'     \item{balanced}{Balanced dataset}
#'     \item{unbalanced}{Unbalanced dataset}
#'   }
#'
#' @examples
#' sim <- simulate_crossover()

simulate_crossover <- function(
    n_subjects = 16,
    seed = 646997,
    drop_subjects = c(5, 6),
    drop_period = 2
) {
  
  set.seed(seed)
  
  # ---- Subjects & sequences ----
  subjects  <- seq_len(n_subjects)
  sequences <- sample(rep(c("TR", "RT"), length.out = n_subjects))
  
  treatments_seq <- list(
    TR = c("T", "R"),
    RT = c("R", "T")
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
  
  # ---- Variance components ----
  var_components <- tribble(
    ~Parameter,       ~between_sd, ~within_sd,
    "AUC0_tz",             0.3100274, 0.1033928,
    "AUCINF_pred",         0.3078800, 0.1015943,
    "Cmax",                0.2241883, 0.1650787
  )
  
  # ---- Combine parameters ----
  log_params <- mu_table %>%
    left_join(var_components, by = "Parameter")
  
  param_levels <- unique(log_params$Parameter)
  
  # ---- Crossover design ----
  design <- tibble(
    Subject  = factor(subjects),
    Sequence = factor(sequences)
  ) %>%
    mutate(sequence = map(Sequence, ~ treatments_seq[[.x]])) %>%
    unnest_longer(sequence,
                  values_to  = "Treatment",
                  indices_to = "Period") %>%
    mutate(
      Period    = factor(Period),
      Treatment = factor(Treatment)
    )
  
  # ---- Subject random effects ----
  subject_effects <- expand_grid(
    Subject   = factor(subjects),
    Parameter = param_levels
  ) %>%
    left_join(var_components, by = "Parameter") %>%
    mutate(subject_re = rnorm(n(), mean = 0, sd = between_sd)) %>%
    select(Subject, Parameter, subject_re)
  
  # ---- Simulate PK ----
  sim_data <- design %>%
    crossing(Parameter = param_levels) %>%
    left_join(log_params,
              by = c("Treatment", "Parameter")) %>%
    left_join(subject_effects,
              by = c("Subject", "Parameter")) %>%
    mutate(
      residual = rnorm(n(), mean = 0, sd = within_sd),
      logPK    = mu + subject_re + residual,
      PK       = exp(logPK),
      Treatment = relevel(factor(Treatment), ref = "R")
    ) %>%
    select(Subject, Sequence, Period,
           Treatment, Parameter,
           logPK, PK) %>%
    arrange(Parameter, Subject, Period)
  
  # ---- Unbalanced version ----
  sim_data_un <- sim_data %>%
    filter(!(Subject %in% drop_subjects &
               Period  == drop_period))
  
  # ---- Return ----
  list(
    balanced   = sim_data,
    unbalanced = sim_data_un
  )
}
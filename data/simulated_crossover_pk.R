library(dplyr) 
library(purrr)  
library(tidyr)    

# DATASET SIMULATION ----
set.seed(646997)  # Reproducibility

# Simulation parameters
n_subjects <- 16
subjects <- 1:n_subjects
sequences <- sample(rep(c("TR", "RT"), length.out = n_subjects))

# Treatment order by sequence
treatments_seq <- list(
  TR = c("T", "R"),
  RT = c("R", "T")
)

# Mean (log-scale) values
mu_table <- tibble::tribble(
  ~Treatment, ~Parameter,       ~mu,
  "T",        "AUC0_tz",        6.146901,
  "T",        "AUCINF_pred",    6.173306,
  "T",        "Cmax",           5.098963,
  "R",        "AUC0_tz",        6.248518,
  "R",        "AUCINF_pred",    6.265877,
  "R",        "Cmax",           5.088447
)

# Variance components
var_components <- tibble::tribble(
  ~Parameter,       ~between_sd, ~within_sd,
  "AUC0_tz",             0.3100274, 0.1033928,
  "AUCINF_pred",         0.3078800, 0.1015943,
  "Cmax",                0.2241883, 0.1650787
)

# Combine mu and variance
log_params <- mu_table %>%
  left_join(var_components, by = "Parameter")

param_levels <- unique(log_params$Parameter)

# Crossover design
design <- tibble(
  Subject = factor(subjects),
  Sequence = factor(sequences)
) %>%
  mutate(sequence = map(Sequence, ~ treatments_seq[[.x]])) %>%
  unnest_longer(sequence, values_to = "Treatment", indices_to = "Period") %>%
  mutate(
    Period = factor(Period),
    Treatment = factor(Treatment)
  )

# Subject-level random effects
subject_effects <- expand_grid(
  Subject = factor(subjects),
  Parameter = param_levels
) %>%
  left_join(var_components, by = "Parameter") %>%
  mutate(subject_re = rnorm(n(), mean = 0, sd = between_sd)) %>%
  select(Subject, Parameter, subject_re)

# Simulate data
sim_data <- design %>%
  crossing(Parameter = param_levels) %>%
  left_join(log_params, by = c("Treatment", "Parameter")) %>%
  left_join(subject_effects, by = c("Subject", "Parameter")) %>%
  mutate(
    residual = rnorm(n(), mean = 0, sd = within_sd),
    logPK = mu + subject_re + residual,
    PK = exp(logPK),
    Treatment = relevel(factor(Treatment), ref = "R")
  ) %>%
  select(Subject, Sequence, Period, Treatment, Parameter, logPK, PK) %>%
  arrange(Parameter, Subject, Period)

saveRDS(sim_data, "data/simulated_crossover_pk.rds")  # for scripts

write.csv(sim_data, "data/simulated_crossover_pk.csv", row.names = FALSE)  #for inspection

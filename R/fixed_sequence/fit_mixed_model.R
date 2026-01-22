# Define mixed-effects model function
fit_mixed_fs <- function(data) {
  
  # Fit the mixed-effects model
  model <- lmer(logPK ~ (1|Subject) + Treatment, data = data)
  
  # Estimated marginal means and contrasts
  fit <- emmeans(model, ~ Treatment, level = 0.9)
  diff <- contrast(fit, method = "revpairwise")
  
  # Return results as a list
  smry <- list(
    emmeans_summary  = summary(fit),
    contrast_summary = summary(diff, infer = TRUE),
    sigma            = summary(model)[["sigma"]]
  )
  return(smry)
}
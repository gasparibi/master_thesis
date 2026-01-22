# Define model function
fit_pg <- function(data) {
  
  # Fit the model
  model <- gls(logPK ~ Treatment, data = data, weights = varIdent(form = ~1 | Treatment))
  
  # Estimated marginal means and contrasts
  fit <- emmeans(model, ~ Treatment, level = 0.9)
  diff <- contrast(fit, method = "revpairwise")
  
  # Extracting coefficients to calculate group-specific residual SDs
  sigma_vals <- sigma(model) * c(R = 1, coef(model$modelStruct$varStruct, unconstrained = FALSE))
  
  # Return results as a list
  smry <- list(
    emmeans_summary  = summary(fit),
    contrast_summary = summary(diff, infer = TRUE),
    sigma_R          = sigma_vals["R"],
    sigma_T          = sigma_vals["T"]
  )
  return(smry)
}
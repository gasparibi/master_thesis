# Fixed-effects model validation 
validate_fixed_model <- function(df, param_name) {
  message("Fixed effects model: ", param_name)
  
  model <- lm(logPK ~ Sequence + Subject:Sequence + Period + Treatment, data = df)
  resid_vals <- resid(model)
  fitted_vals <- fitted(model)
  
  qqnorm(resid_vals, main = paste("Q-Q Plot -", param_name, "(Fixed)"))
  qqline(resid_vals, col = "red")
  
  plot(fitted_vals, resid_vals,
       main = paste("Residuals vs Fitted -", param_name, "(Fixed)"),
       xlab = "Fitted values", ylab = "Residuals",
       pch = 19, col = "gray")
  abline(h = 0, col = "red")
}

# Mixed-effects model validation
validate_mixed_model <- function(df, param_name) {
  message("Mixed effects model: ", param_name)
  
  model <- lmer(logPK ~ Sequence + (1|Subject:Sequence) + Period + Treatment, data = df)
  resid_vals <- resid(model)
  fitted_vals <- fitted(model)
  
  qqnorm(resid_vals, main = paste("Q-Q Plot -", param_name, "(Mixed)"))
  qqline(resid_vals, col = "red")
  
  plot(fitted_vals, resid_vals,
       main = paste("Residuals vs Fitted -", param_name, "(Mixed)"),
       xlab = "Fitted values", ylab = "Residuals",
       pch = 19, col = "gray")
  abline(h = 0, col = "red")
}

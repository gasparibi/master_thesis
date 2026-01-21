model <- gls(logpk ~ treatment, data = indata, weights = varIdent(form = ~1 | treatment))
fit <- emmeans(model, ~ treatment, level = 0.9)
diff <- contrast(fit, method = "revpairwise")

sigma_vals <- sigma(model) * c(R = 1, coef(model$modelStruct$varStruct, unconstrained = FALSE))

smry <- list(
  emmeans_summary  = summary(fit),
  contrast_summary = summary(diff, infer = TRUE),
  sigma_R          = sigma_vals["R"],
  sigma_T          = sigma_vals["T"]
)
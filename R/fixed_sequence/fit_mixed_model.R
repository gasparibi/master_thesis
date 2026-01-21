model <- lmer(logpk ~ (1|subject) + treatment, data = indata)
fit <- emmeans(model, ~ treatment, level = 0.9)
diff <- contrast(fit, method = "revpairwise")

smry <- list(
  emmeans_summary  = summary(fit),
  contrast_summary = summary(diff, infer = TRUE),
  sigma            = summary(model)[["sigma"]]
)
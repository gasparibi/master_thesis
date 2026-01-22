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
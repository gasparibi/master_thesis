make_forest_plot <- function(final_table, params, ep_group, x_limits = c(60, 130), ref_lines = c(80, 100, 125)) {
  
  plot_data <- final_table %>%
    filter(
      !is.na(lower), lower != "",
      !is.na(upper), upper != ""
    ) %>%
    mutate(
      ratio = as.numeric(ratio),
      lower = as.numeric(lower),
      upper = as.numeric(upper),
      Parameter = factor(rep(params, each = 1), levels = c("Cmax", "AUC0_tz", "AUCINF_pred")),
      Group = ep_group
    ) %>%
    arrange(Parameter) %>%
    select(Parameter, Group, ratio, lower, upper)
  
  ggplot(plot_data, aes(y = Parameter, x = ratio)) +
    geom_point(color = "blue", size = 3) +
    geom_errorbarh(aes(xmin = lower, xmax = upper), height = 0.2, color = "blue", linewidth = 1) +
    geom_vline(xintercept = 100, linetype = "dashed", color = "black") +
    geom_vline(xintercept = c(80, 125), linetype = "solid", color = "black") +
    facet_wrap(~ Group, ncol = 1, scales = "free_y") +
    scale_x_continuous(name = "(%)", limits = x_limits) +
    ylab("PK parameter") +
    theme_minimal(base_size = 13) +
    theme(strip.text = element_text(size = 14), panel.spacing = unit(1, "lines"))
}
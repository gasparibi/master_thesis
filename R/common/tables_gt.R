# First table
prepare_table <- function(model_results, indata, parameter, group) {
  
  back_transformed <- back_transform(model_results)
  
  adj <- back_transformed$adjusted
  rat <- back_transformed$ratio
  gcv <- back_transformed$variab
  
  n_per_param <- indata %>%
    filter(Parameter == parameter) %>%
    group_by(Treatment) %>%
    summarise(n = n_distinct(Subject), .groups = "drop")
  
  adj <- adj %>%
    left_join(n_per_param, by = "Treatment") %>%
    select(Treatment, n, adj_gmean, adj_gse) %>%
    mutate(Group = group)
  
  adj <- adj %>%
    mutate(
      n = as.character(n),
      adj_gmean = sprintf("%.2f", adj_gmean),
      adj_gse   = sprintf("%.2f", adj_gse),
      ratio = ifelse(row_number() == 1, sprintf("%.2f", rat$ratio * 100), ""),
      gse   = ifelse(row_number() == 1, sprintf("%.2f", rat$gse), ""),
      lower = ifelse(row_number() == 1, sprintf("%.2f", rat$lower * 100), ""),
      upper = ifelse(row_number() == 1, sprintf("%.2f", rat$upper * 100), ""),
      gCV   = ifelse(row_number() == 1, sprintf("%.1f", gcv * 100), "")
    )
  
  parameter_row <- tibble(
    Treatment = parameter,
    n = "",
    adj_gmean = "",
    adj_gse = "",
    ratio = "",
    gse = "",
    lower = "",
    upper = "",
    gCV = "",
    Group = group
  )
  
  bind_rows(parameter_row, adj)
}

# gt table
make_gt_table <- function(final_table, model_type = c("fixed", "mixed")) {
  
  model_type <- match.arg(model_type)
  
  subject_label <- switch(
    model_type,
    fixed = "fixed effect",
    mixed = "random effect"
  )
  
  title_text <- paste0(
    "Adjusted Geometric Means and Relative Bioavailability  \n",
    "of Treatment (T) vs Reference (R) with subject as ",
    subject_label,
    " - PKS"
  )
  
  final_table %>%
    gt(
      groupname_col = "Group",
      rowname_col   = "Treatment"
    ) %>%
    tab_header(
      title = md(title_text)
    ) %>%
    cols_label(
      adj_gmean = "gMean",
      adj_gse   = "gSE",
      ratio     = "Ratio (T/R) %",
      gse       = "gSE",
      lower     = "Lower (%)",
      upper     = "Upper (%)",
      gCV       = "gCV (%)"
    ) %>%
    tab_spanner(
      label   = "Adjusted",
      columns = c(adj_gmean, adj_gse)
    ) %>%
    tab_spanner(
      label   = "90% Confidence Interval",
      columns = c(lower, upper),
      id      = "ci_spanner"
    ) %>%
    tab_spanner(
      label    = "Comparison vs Reference (R)",
      columns  = c(ratio, gse, lower, upper, gCV),
      spanners = "ci_spanner"
    ) %>%
    tab_footnote(
      footnote  = "n = number of observations included in the analysis 
                   of each treatment",
      locations = cells_column_labels(columns = n)
    ) %>%
    tab_footnote(
      footnote  = "intra-individual gCV",
      locations = cells_column_labels(columns = gCV)
    ) %>%
    tab_source_note(
      source_note = md(format(Sys.Date(), "%B %d, %Y"))
    ) %>%
    tab_options(
      table.width            = pct(100),
      heading.title.font.size = px(16)
    )
}

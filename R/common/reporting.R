###############################################################################
# File: reporting.R
#
# Purpose:
#   Defines functions to render formatted reporting outputs from
#   relative bioavailability analyses, including summary tables and
#   forest plots.
#
# Description:
#   These utilities take fully formatted analysis tables created by
#   prepare_table() / build_final_table() and:
#     - produce publication-ready gt tables,
#     - generate forest plots of geometric mean ratios with 90% CI,
#     - adapt titles and annotations based on study design
#       (crossover, fixed-sequence, or parallel-group).
#
# Intended for:
#   - Phase 1 bioavailability assessment
#   - SAS-to-R comparison
#   - Quarto-based statistical reports
#
# Contents:
#   - make_gt_table(): render summary tables using gt.
#   - make_forest_plot(): draw forest plots of T/R ratios and confidence
#       intervals.
#
# Dependencies:
#   dplyr, ggplot2, gt
#
# Author: Bianca Gasparini
###############################################################################

library(dplyr)
library(ggplot2)
library(gt)

#' Render formatted relative bioavailability table
#'
#' Creates a publication-ready \code{gt} table summarizing adjusted
#' geometric means, treatment ratios, 90\% confidence intervals, and
#' geometric coefficients of variation (gCV).
#'
#' Table titles and gCV footnotes are automatically adapted to the
#' selected study design (crossover, fixed-sequence, or parallel-group).
#'
#' @param final_table A formatted table produced by
#'   \code{build_final_table()}.
#' @param design Study design. One of \code{"crossover"},
#'   \code{"fixed_sequence"}, or \code{"parallel"}.
#' @param model_type Model formulation used for subject effects:
#'   \code{"fixed"} or \code{"mixed"}.
#' @param dataset_type Dataset structure:
#'   \code{"balanced"} or \code{"unbalanced"}.
#'
#' @return A \code{gt_tbl} object suitable for rendering in Quarto
#'   or exporting to HTML or PDF.
#'
#' @seealso \code{\link{prepare_table}}, \code{\link{build_final_table}},

make_gt_table <- function(final_table,
                          design = c("crossover", "fixed_sequence", "parallel"),
                          model_type = c("fixed", "mixed"),
                          dataset_type = c("balanced", "unbalanced")) {
  
  design <- match.arg(design)
  model_type <- match.arg(model_type)
  dataset_type <- match.arg(dataset_type)
  
  subject_label <- switch(
    model_type,
    fixed = "fixed effect",
    mixed = "random effect"
  )
  
  dataset_label <- switch(
    dataset_type,
    balanced = "balanced dataset",
    unbalanced = "unbalanced dataset"
  )
  
  # -----------------------------
  # Shared strings
  # -----------------------------
  
  xo_title <- paste0(
    "Adjusted geometric means and relative bioavailability of treatment (T) vs reference (R) with subject as ",
    subject_label,
    " - ", dataset_label
  )
  
  parallel_title <- "Adjusted geometric means and relative bioavailability of treatment (T) vs reference (R)"
  
  intra_gcv_note <- "intra-individual gCV"
  pooled_gcv_note <- "calculated from pooled variance"
  
  # -----------------------------
  # Design-specific logic
  # -----------------------------
  
  title_text <- switch(
    design,
    parallel        = parallel_title,
    fixed_sequence  = xo_title,
    crossover       = xo_title
  )
  
  gcv_note <- switch(
    design,
    parallel        = pooled_gcv_note,
    fixed_sequence  = intra_gcv_note,
    crossover       = intra_gcv_note
  )
  
  # -----------------------------
  # Build table
  # -----------------------------
  
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
      ratio     = "Ratio (T/R, %)",
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
      label    = "Comparison vs reference (R)",
      columns  = c(ratio, gse, lower, upper, gCV),
      spanners = "ci_spanner"
    ) %>%
    tab_footnote(
      footnote  = "n = number of observations included in the analysis 
                   of each treatment",
      locations = cells_column_labels(columns = n)
    ) %>%
    tab_footnote(
      footnote  = gcv_note,
      locations = cells_column_labels(columns = gCV)
    ) %>%
    tab_source_note(
      source_note = md(format(Sys.Date(), "%B %d, %Y"))
    ) %>%
    tab_options(
      table.width             = pct(100),
      heading.title.font.size = px(16)
    )
}

#' Create forest plot of relative bioavailability results
#'
#' Generates a forest plot of geometric mean ratios (T/R, \%) with
#' 90\% confidence intervals across PK parameters.
#'
#' Plot titles are automatically adapted to the study design
#' (crossover, fixed-sequence, or parallel-group).
#'
#' @param final_table A formatted table produced by
#'   \code{build_final_table()}.
#' @param design Study design. One of \code{"crossover"},
#'   \code{"fixed_sequence"}, or \code{"parallel"}.
#' @param model_type Model formulation used for subject effects:
#'   \code{"fixed"} or \code{"mixed"}.
#' @param dataset_type Dataset structure:
#'   \code{"balanced"} or \code{"unbalanced"}.
#' @param x_limits Numeric vector of length two defining x-axis limits.
#' @param ref_lines Numeric vector defining reference lines
#'   (e.g., 80, 100, 125).
#'
#' @return A \code{ggplot} object displaying the forest plot.
#'
#' @details
#' Solid vertical lines at 80\% and 125\% correspond to typical
#' bioequivalence acceptance bounds, while the dashed line at 100\%
#' indicates equality between treatments.
#'
#' @seealso \code{\link{make_gt_table}}, \code{\link{build_final_table}}

make_forest_plot <- function(final_table,
                             design = c("crossover", "fixed_sequence", "parallel"),
                             model_type = c("fixed", "mixed"),
                             dataset_type = c("balanced", "unbalanced"),
                             x_limits = c(60, 130),
                             ref_lines = c(80, 100, 125)) {
  
  design <- match.arg(design)
  model_type <- match.arg(model_type)
  dataset_type <- match.arg(dataset_type)
  
  subject_label <- switch(
    model_type,
    fixed = "fixed effect",
    mixed = "random effect"
  )
  
  dataset_label <- switch(
    dataset_type,
    balanced = "balanced dataset",
    unbalanced = "unbalanced dataset"
  )
  
  # -----------------------------
  # Shared strings
  # -----------------------------
  
  xo_title <- paste0(
    "Relative bioavailability of treatment (T) vs reference (R)\n",
    "with subject as ",
    subject_label,
    " - ", dataset_label
  )
  
  parallel_title <- "Relative bioavailability of treatment (T) vs reference (R)"
  
  # -----------------------------
  # Design-specific title logic
  # -----------------------------
  
  title_text <- switch(
    design,
    parallel        = parallel_title,
    fixed_sequence  = xo_title,
    crossover       = xo_title
  )
  
  # -----------------------------
  # Build plotting dataset
  # -----------------------------
  
  params <- endpoint_map$Parameter
  Group  <- endpoint_map$Group
  
  plot_data <- final_table %>%
    filter(
      !is.na(lower), lower != "",
      !is.na(upper), upper != ""
    ) %>%
    mutate(
      ratio = as.numeric(ratio),
      lower = as.numeric(lower),
      upper = as.numeric(upper),
      Parameter = factor(rep(params, each = 1),
                         levels = c("Cmax", "AUC0_tz", "AUCINF_pred")),
      Group = factor(Group)
    ) %>%
    arrange(Parameter) %>%
    select(Parameter, Group, ratio, lower, upper)
  
  # -----------------------------
  # Plot
  # -----------------------------
  
  ggplot(plot_data, aes(y = Parameter, x = ratio)) +
    geom_point(color = "blue", size = 3) +
    geom_errorbarh(
      aes(xmin = lower, xmax = upper),
      height = 0.2,
      color = "blue",
      linewidth = 1
    ) +
    geom_vline(xintercept = 100, linetype = "dashed", color = "black") +
    geom_vline(xintercept = ref_lines[ref_lines != 100],
               linetype = "solid", color = "black") +
    facet_wrap(~ Group, ncol = 1, scales = "free_y") +
    scale_x_continuous(name = "gMean ratio (T/R, %)", limits = x_limits) +
    ylab("PK parameter") +
    ggtitle(title_text) +
    theme_minimal(base_size = 13) +
    theme(
         plot.title = element_text(
            hjust = 0.5,
            size = 14,
            face = "bold",
            margin = margin(b = 10)
          ),
         strip.text = element_text(size = 14),
         panel.spacing = unit(1, "lines"),
         plot.margin = margin(15, 15, 15, 15)
      )
}

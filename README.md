# Relative Bioavailability Analysis: R vs SAS

This repository provides a fully reproducible workflow to compare R and SAS implementations for analyzing relative bioavailability in Phase 1 clinical trials. 
The main example is a full case-study report for a 2×2 crossover design, but the underlying R pipeline and dataset generation also support fixed-sequence and parallel-group study designs.

The project demonstrates how R can reproduce regulatory-style outputs typically produced with SAS and highlights any minor differences between software platforms.

---

## Overview

- **Study designs supported:** crossover, fixed-sequence, and parallel-group (simulated datasets included).  
- **Models implemented:** fixed-effects and mixed-effects ANOVA.  
- **Comparison:** R outputs are benchmarked against SAS results for reproducibility and regulatory compliance.  
- **Outputs:** regulatory-style tables and forest plots for treatment comparisons.  

**Note**: The included Quarto report focuses on the crossover design as an illustrative example. The R functions and dataset-simulating utilities can be applied to all supported study designs.

---

## Repository Structure

```
master_thesis/
├── data/                          # Simulated datasets and generators
│   ├── crossover/
│   ├── fixed_sequence/
│   └── parallel_group/
│
├── R/                             # R analysis pipelines and helpers
│   ├── common/
│   ├── crossover/
│   ├── fixed_sequence/
│   └── parallel_group/
│
├── SAS/                           # SAS implementations for benchmarking
│   ├── common/
│   ├── crossover/
│   ├── fixed_sequence/
│   └── parallel_group/
│
├── output/                        # Quarto report and saved images
│   └── crossover/
│
├── .Rprofile                      # Activates renv environment automatically
├── renv.lock                      # Locked package versions for reproducibility
├── master_thesis.Rproj
├── README.md
├── LICENSE
└── .gitignore
```

The repository is organized so that simulation code, R pipelines, and SAS programs mirror each other across study designs, facilitating direct cross-platform comparisons.

---

## How to render the crossover report

### 1. Clone the repository

```
git clone https://github.com/gasparibi/master_thesis.git
cd master_thesis
```

### 2. Open in RStudio

Double-click the `.Rproj` file in the repository root.

### 3. Install dependencies

This project uses `renv` to manage R package versions. To recreate the R environment:

```
install.packages("renv")  # if not already installed
renv::restore()
```

This ensures that all R packages used in the analyses are installed with the correct versions.

### 4. Render the Quarto report

From the project root:

```
quarto render output/crossover/crossover_case_study.qmd
```

- The HTML report will be generated in the same folder.
- All R-based tables and figures are saved in `output/crossover/images/R/`.
- SAS outputs (used for benchmarking) are saved in `output/crossover/images/SAS/` and can be reproduced using `SAS/crossover/example/run_crossover.sas`.

The same R functions can be adapted to generate reports for fixed-sequence and parallel-group designs by providing the corresponding dataset and changing parameters in the functions.

---

## Software and Package Versions

- **R**: 4.5.2
- **Quarto**: 1.7.33
- **SAS**: 9.4 (TS1M7)

**Key R packages:**

`dplyr`, `emmeans`, `ggplot2`, `gt`, `lme4`, `pbkrtest`, `purrr`, `tidyr`

*Exact versions are recorded in `renv.lock`.*

---

## License

This project is licensed under the MIT License. 
See the [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE) file for details.

---

## Citation

If you use this repository in your work, please cite:

Gasparini, B. (2026). *R and SAS comparison for relative bioavailability studies in Phase 1 clinical trials.*

# Figure 4e Audit & Visual Rework

> **A Reproducible Computational Reanalysis of David E. Olson Lab's 2021 Nature Publication**
>
> *Author: Isaac McGinn (University of California, Davis)*

[![Quarto](https://img.shields.io/badge/Render-Quarto-blue?logo=quarto)](https://quarto.org/)
[![Language](https://img.shields.io/badge/Language-R%20%28v4.4%2B%29-blue?logo=r)](https://www.r-project.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Project Overview

Serotonergic psychedelics such as psilocybin and LSD as well as atypical psychedelics like **ibogaine** have proven to be profoundly effective in treating neuropsychiatric disorders, including substance use disorders. However, their therapeutic use is limited by their intense hallucinogenic side effects and, in the case of ibogaine, the risk of fatal cardiac arrhythmias through inhibition of the hERG potassium channel.

In order to overcome these barriers, the Olson Lab at the University of California, Davis developed **tabernanthalog (TBG)**, a water-soluble, non-hallucinogenic, and non-toxic analogue of ibogaine. TBG retains the neural plasticity properties of ibogaine while eliminating hallucinogenic effects and cardiac toxicity (Cameron et al., 2021).

In this computational reanalysis and visual redesign, I utilize raw, unpolished behavioral data deposited on Figshare (ID: 11634795) from the publication:

> Cameron, L.P., Tombari, R.J., Lu, J. *et al.* A non-hallucinogenic psychedelic analogue with therapeutic potential. *Nature* **589**, 474–479 (2021). [https://doi.org/10.1038/s41586-020-3008-z](https://doi.org/10.1038/s41586-020-3008-z)

My main objective is to audit figure 4e (Alcohol Intake Over Time), verifying whether a single administration of TBG (10 mg/kg) significantly reduces daily alcohol consumption in mice across multiple days. Additionally, I aim to replicate the published figure and attempt to improve clarity by replacing the original **dynamite plot** with a high-density visualization that reveals the underlying variability between mice.

## Repository Structure

The project directory is organized according to professional data-science standards:

```
Tabernanthalog_Audit/
├── data/
│   ├── raw/
│   │   └── extracted/           # Raw Figshare publication data (PZFX format)
│   └── processed/
│       └── tidy_alcohol_consumption.csv   # Long-format cleaned dataset
├── scripts/
│   ├── 01_tidy_alcohol.R        # R script to extract, tidy, and export data
│   └── scratchpad.R             # Scratchpad for exploratory analyses
└── report/
    ├── index.qmd                # Main Quarto analysis report
    ├── index.html               # Compiled, interactive HTML portfolio piece
    └── published_figure_4e.png  # Reference image of original Figure 4e
```

## Reproduction Guide

To run the tidying scripts, reproduce the statistical models, and render the final reports locally, follow these steps:

### Prerequisites

You must have **R (v4.4+)** and **Quarto CLI** installed.

### 1. Install Dependencies

An automated installer script is provided. Execute the following in R or your terminal to fetch the required packages (`tidyverse`, `broom`, `emmeans`, `pzfx`, `here`):

```
install.packages(c("tidyverse", "broom", "emmeans", "pzfx", "here"), repos = "https://cloud.r-project.org")
```

### 2. Run Data Tidying Pipeline

To regenerate the processed long-format CSV from raw source files:

```
Rscript scripts/01_tidy_alcohol.R
```

### 3. Compile and Render the Quarto Report

Compile the comprehensive computational report to self-contained interactive HTML and print-ready PDF formats:

```
quarto render report/index.qmd
```

---

## Statistical Validation & Conclusions

### ANOVA Conclusion
* **'treatment'** -> significant ($p < 0.001$, \*\*\*): TBG reduced alcohol intake overall.
* **'day'** -> significant ($p < 0.001$, \*\*\*): intake changed across days, regardless of treatment.
* **'treatment', 'day' interaction** -> not significant ($p = 0.117$)

The test above yielded three statistical findings:
* **'treatment' effect is very significant.** Mice treated with a single dose of TBG consumed significantly less alcohol than vehicle-treated controls across the timeline. The primary therapeutic claim is fully supported.
* **'day' effect is very significant.** Regardless of treatment, overall alcohol consumption changed significantly over time.
* **The 'treatment' and 'day' interaction is not statistically significant.**

The original publication figure shows a convergence between 'treatment' over time, implying that TBG's efficacy fades over time. However, the non-significant interaction term cannot confirm this pattern. This does not yet serve as a contradiction to the published figure but warrants the use of a **post-hoc** test to investigate how the authors derived their daily significance markers.

### Post-Hoc Tukey HSD Conclusion
Using the conservative post-hoc Tukey HSD test, none of the day-specific treatment comparisons (VEH vs. TBG) reached statistical significance. Day 1 was closest to reaching significance.

Hope is not lost, I will now apply the exact methodology used in the publication to determine significance: the **Sidak Multiple Comparisons Test**.

### Sidak Conclusion
This test has proven to reproduce the published figure's pattern. High significance at day 1 ($p < 0.001$) and reduced significance on day 2 ($p < 0.05$), corresponding to the pattern of convergence between treatments over time seen in the published figure.

---

## Issues with the Published Figure & Improved Design

### Issues With the Published Figure
The published figure presents only mean +/- 'SEM' each day, making it a 'dynamite plot'. This format is clean and easily readable, though it hides the underlying individual mouse data points. Readers have no way to tell variance between mice each day. Additionally, the X-axis time scale has even spacing despite there being more time between day 2 and 5 than day 1 and 2. Finally, information would be lost if the figure were to be printed 'gray-scale' and the colors used are not colorblind friendly.

### Improved Figure Design
In an attempt to address the issues explained above, I plotted each mouse trajectory as thin, semi-transparent lines and points underneath the summary layer data created earlier. I soon realized that overlaying both treatment groups was cluttered and hard to read, so I used `facet_wrap()` to split the data into two figures, grouped by treatment. The issue of even spacing on the X-axis was easily mended by leaving out `as.factor()` from the `day` variable, making the spacing continuous and numeric. Next, color was corrected using the colorblind-safe palette `scale_color_viridis_d()`.

Some big trade-offs were made by changing the figure like this. I certainly appreciate the choices made for the published figure more now. The main issues with this new plot are the disjointed nature caused by faceting and increased visual noise coming from plotting every mouse trajectory.

---

## Final Notes and Acknowledgements

This project served as a valuable learning experience for me. I have been 'teaching myself' (reading books) R, tidyverse workflows, and Quarto for the past few months. I am so thankful for the resources available to me such as the books: (R for Data Science, Fundamentals of Data Visualization, Bioinformatics Data Skills, Envisioning Information, and Storytelling with Data) which I will link below. I started this project without ever having learned of packages like `emmeans` or the 'Sidak' post-hoc test. I thank YouTube for the tutorials needed to work through that. I have a lot more work to do before I can consider myself proficient at R but I am glad to have finished this project, working with real data, as a first 'proof' of my learning so far.

* [R for Data Science](https://r4ds.hadley.nz)
* [Fundamentals of Data Visualization](https://clauswilke.com/dataviz/)
* [Bioinformatics Data Skills](https://www.oreilly.com/library/view/bioinformatics-data-skills/9781449367480/)
* [Envisioning Information](https://www.edwardtufte.com/tufte/books_ei)
* [Storytelling with Data](https://www.storytellingwithdata.com/books)

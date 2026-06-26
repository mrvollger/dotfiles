---
name: r-plotting
description: >
  Make publication-style R figures the Vollger Lab way, using the mrvplot helpers
  (https://github.com/vollgerlab/mrvplot) and the R-template environment
  (https://github.com/vollgerlab/R-template). Use when asked to plot data in R, build a ggplot2
  figure or an R Markdown (.Rmd) figure report, set up an R plotting environment with pixi, save
  figures with their underlying data, or work with the mrv_* helper functions and lab color
  palettes. Bundles a plotting .Rmd template, a standalone utils.R of the helpers, and a pixi.toml.
---

# R plotting (Vollger Lab / mrvplot + R-template)

Build clean, publication-ready ggplot2 figures and `.Rmd` figure reports. Two sources back this:

- **mrvplot** (`https://github.com/vollgerlab/mrvplot`): a small package of `mrv_*` plotting helpers.
  Install with `devtools::install_github("vollgerlab/mrvplot")`, then `library(mrvplot)`.
- **R-template** (`https://github.com/vollgerlab/R-template`): the standard pixi R environment plus
  an `Rscripts/utils.R` of inline helpers and lab color palettes.

For a quick figure, source the bundled `templates/utils.R` (standalone, no install needed). For a
project, use the pixi env and either install mrvplot or copy the helpers.

## Setup (pixi)

```bash
pixi install            # see templates/pixi.toml for the full R dependency set
pixi run radian         # interactive R; r-languageserver is included for editor support
```

Channels: `conda-forge`, `bioconda`. Don't `install.packages()` into a pixi-managed env; add deps
to `pixi.toml` instead. Heavy stack already pinned: tidyverse, data.table, cowplot, ggpubr, scales,
glue, ggforce, patchwork, ggridges, pals, etc.

## The mrvplot helpers

- `mrv_grid()`, `mrv_hgrid()`, `mrv_vgrid()`: cowplot `theme_minimal_grid` family at `FONT_SIZE = 6`.
  Default to `mrv_grid()`; never ship the gray ggplot background.
- `mrv_theme_no_x()`: drop x-axis title/text/ticks (for stacked panels).
- `mrv_ggsave(file, ...)`: `ggsave` that **also** writes the plot's data to `Tables/<name>.tbl.gz`
  and copies the figure to `tmp.<ext>`. Use it instead of `ggsave`: it gives you the per-panel data
  table journals now ask for, and the `tmp.*` copy is a live preview when working over VS Code/SSH.
- `scientific_10()`: base-10 scientific-notation axis labels.
- `reverselog_trans()`, `logit_e()`/`anti_logit_e()`, `trans_anti_logit_e`: scale transforms.
- `mrv_read_bed(...)`: `fread` a BED with the first 3 cols renamed `chrom/start/end` and sorted.

## Saving figures (rules of thumb)

- Save at **~3 in wide × 3 in tall**: roughly one journal panel; scale from there.
- If a plot looks wrong, **change the font size before the figure size**.
- Always export the data behind a figure. `mrv_ggsave()` does this automatically into `Tables/`.

## My favorite plot (large-data scatter recipe)

For genomics scatter (many points, looking for correlation), evolve points → hexbin so density and
hidden clusters show, and so the SVG opens in Illustrator/Inkscape without a million points:

```r
ggplot(data, aes(x, y)) +
  geom_hex(bins = 50) +
  scale_fill_distiller("", palette = "Spectral", trans = "log10") +
  geom_abline(slope = 1, intercept = 0, color = "darkred", linetype = "dashed") +
  coord_fixed() +
  ggpubr::stat_cor(size = 2) +
  scale_x_continuous("x label", labels = scales::percent) +
  scale_y_continuous("y label", labels = scales::percent) +
  mrv_grid() +
  theme(legend.position = "right")
```

See `templates/plot.Rmd` for the full stepwise build and `.Rmd` chunk conventions
(`fig.width = 3, fig.height = 3, dpi = 200, dev = "png"`, `comment = "#>"`).

## Conventions

- Format R with `styler` (`pixi run format` in template projects; `styler::style_dir(".")`).
- Document package functions with roxygen2; use `devtools` for build/check/install.
- Lab color palette (from R-template `utils.R`, bundled here): `Red`, `Indigo`, `Yellow`, `Teal`,
  `Gray`, and `MODEL_COLORS` for fiberseq m6A model comparisons.
- For fiberseq/m6A tables, `read_m6a()` in `templates/utils.R` parses fibertools output (m6A,
  nucleosome, MSP intervals) into a long data.table ready to plot.

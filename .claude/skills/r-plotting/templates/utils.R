# Vollger Lab R plotting helpers (standalone).
# Source this for a quick figure: source("utils.R")
# The mrv_* functions mirror the mrvplot package
# (https://github.com/vollgerlab/mrvplot); install that for the documented,
# packaged versions. Niche helpers from R-template (facet_zoom2,
# load_ipd_from_npz, get_maxima_from_plot) are not bundled here; copy them from
# https://github.com/vollgerlab/R-template if needed.

library(tidyverse)
library(data.table)
library(scales)
library(cowplot)
library(glue)
library(ggpubr)
library(patchwork)
suppressWarnings(library(tools))

# ---- Lab color palette ----
Red <- "#c1272d"
Indigo <- "#0000a7"
Yellow <- "#eecc16"
Teal <- "#008176"
Gray <- "#b3b3b3"

MODEL_COLORS <- c(
  PacBio = Indigo,
  CNN = Red,
  XGB = Yellow,
  GMM = Teal,
  IPD = Gray,
  SEMI = "purple",
  Revio = "#f41c90"
)

FONT_SIZE <- 6

# ---- Themes ----
mrv_grid <- function(...) cowplot::theme_minimal_grid(font_size = FONT_SIZE, ...)
mrv_hgrid <- function(...) cowplot::theme_minimal_hgrid(font_size = FONT_SIZE, ...)
mrv_vgrid <- function(...) cowplot::theme_minimal_vgrid(font_size = FONT_SIZE, ...)

mrv_theme_no_x <- function(...) {
  ggplot2::theme(
    axis.title.x = ggplot2::element_blank(),
    axis.text.x = ggplot2::element_blank(),
    axis.ticks.x = ggplot2::element_blank()
  )
}

# ---- Save plot + its data ----
# Writes the figure, exports last_plot()$data to Tables/<name>.tbl.gz, and copies
# the figure to tmp.<ext> for a live preview when working over SSH/VS Code.
mrv_ggsave <- function(file, ...) {
  file <- glue::glue(file)
  print(file)
  ext <- tools::file_ext(file)
  file_without_ext <- tools::file_path_sans_ext(file)
  tbldir <- paste0(dirname(file), "/Tables/")
  tblfile <- paste0(tbldir, basename(file_without_ext), ".tbl.gz")
  if (!dir.exists(tbldir)) dir.create(tbldir, recursive = TRUE)
  ggplot2::ggsave(glue::glue("{file}"), bg = "transparent", ...)
  cmd <- glue::glue("cp {file} tmp.{ext}")
  print(cmd)
  system(cmd)
  data.table::fwrite(ggplot2::last_plot()$data, tblfile, sep = "\t")
  invisible(file)
}

# ---- Scale transforms / label formatters ----
reverselog_trans <- function(base = exp(1)) {
  trans <- function(x) -log(x, base)
  inv <- function(x) base^(-x)
  scales::trans_new(paste0("reverselog-", format(base)), trans, inv,
    scales::log_breaks(base = base),
    domain = c(1e-100, Inf)
  )
}

scientific_10 <- function(x) {
  is_one <- as.numeric(x) == 1
  text <- gsub("e", " %*% 10^", scales::scientific_format()(x))
  text <- stringr::str_remove(text, "^1 %\\*% ")
  text[is_one] <- "10^0"
  parse(text = text)
}

logit_e <- function(x, a = 1, b = 0) {
  z <- x^exp(1)
  log(z / (1 - z))
}

anti_logit_e <- function(x, a = 1, b = 0) {
  z <- exp(b) * x^a
  (z / (1 + z))^exp(-1)
}

trans_anti_logit_e <- scales::trans_new(
  name = "trans_anti_logit_e",
  transform = anti_logit_e,
  inverse = logit_e
)

# ---- BED I/O ----
mrv_read_bed <- function(...) {
  df <- data.table::fread(...)
  names <- colnames(df)
  names[names == "start"] <- "start.other"
  names[names == "end"] <- "end.other"
  names[1:3] <- c("chrom", "start", "end")
  colnames(df) <- names
  df[order(df$chrom, df$start, df$end)]
}

# ---- Fiberseq / m6A ----
# Parse fibertools (ft extract) output into a long data.table of m6A, nucleosome,
# and MSP intervals ready to plot. ref=TRUE uses reference-coordinate columns.
read_m6a <- function(file, my_tag = "", min_ml = 200, nrows = Inf, ref = TRUE) {
  library(IRanges)
  library(splitstackshape)
  tmp <- fread(glue(file), nrows = nrows) %>%
    filter(en - st > 0.5 * fiber_length | (en == 0 & st == 0)) %>%
    filter(ec > 3.9)
  if ("sam_flag" %in% colnames(tmp)) {
    tmp <- tmp %>% filter(sam_flag <= 16)
  }
  tmp <- tmp %>%
    mutate(
      fake_end = dplyr::case_when(en == 0 ~ 11, TRUE ~ as.numeric(en)),
      st = as.numeric(st),
      index = row_number(),
      bin = IRanges::disjointBins(IRanges(st + 1, fake_end) + 150),
    )
  cols <- if (ref) {
    list(m6a = "ref_m6a", nuc = "ref_nuc_starts", nucl = "ref_nuc_lengths",
         msp = "ref_msp_starts", mspl = "ref_msp_lengths")
  } else {
    list(m6a = "m6a", nuc = "nuc_starts", nucl = "nuc_lengths",
         msp = "msp_starts", mspl = "msp_lengths")
  }
  m6a <- tmp %>%
    select(all_of(c(cols$m6a, "fiber", "fiber_length", "RG", "m6a_qual", "bin", "st", "en", "strand"))) %>%
    filter(.data[[cols$m6a]] != ".") %>%
    cSplit(c("m6a_qual", cols$m6a), direction = "long") %>%
    filter(m6a_qual > min_ml) %>%
    mutate(type = "m6A", start = .data[[cols$m6a]], end = start + 1, alpha = 1.0, size = 2)
  nuc <- tmp %>%
    select(all_of(c("fiber", "fiber_length", "RG", cols$nuc, cols$nucl, "bin", "st", "en", "strand"))) %>%
    filter(.data[[cols$nuc]] != ".") %>%
    cSplit(c(cols$nuc, cols$nucl), direction = "long") %>%
    mutate(type = "Nucleosome", start = .data[[cols$nuc]], end = start + .data[[cols$nucl]], alpha = 0.8, size = 1)
  msp <- tmp %>%
    select(all_of(c("fiber", "fiber_length", "RG", cols$msp, cols$mspl, "bin", "st", "en", "strand"))) %>%
    filter(.data[[cols$msp]] != ".") %>%
    cSplit(c(cols$msp, cols$mspl), direction = "long") %>%
    mutate(type = "MSP", start = .data[[cols$msp]], end = start + .data[[cols$mspl]], alpha = 0.8, size = 1)
  bind_rows(list(nuc, m6a, msp)) %>%
    mutate(tag = my_tag) %>%
    filter(start != -1) %>%
    group_by(type, fiber, RG) %>%
    arrange(start) %>%
    mutate(dist = start - lag(start)) %>%
    data.table()
}

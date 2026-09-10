#!/usr/bin/env Rscript
# update_metrics.R --------------------------------------------------------
# Fetches lab-level scholarship metrics (citations, h-index, i10) from
# Google Scholar and writes them to _metrics.yml.
#
# publications.qmd reads _metrics.yml at render time and displays the
# numbers in the page header. Re-run this script whenever you want to
# refresh the values (e.g. monthly), then re-render the site.
#
# Usage:
#   Rscript R/update_metrics.R
#
# Requirements (install once):
#   install.packages(c("scholar", "yaml"))
# -------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(scholar)
  library(yaml)
})

scholar_id <- "qDwcLvIAAAAJ"          # Diogo's Google Scholar user ID

# Google Scholar throttles requests aggressively; wrap in tryCatch so a
# failure here does NOT block the site from rendering.
prof <- tryCatch(
  scholar::get_profile(scholar_id),
  error = function(e) {
    message("[update_metrics] Scholar fetch failed: ", conditionMessage(e))
    NULL
  }
)

if (is.null(prof)) {
  message("[update_metrics] No update written. Existing _metrics.yml (if any) ",
          "is preserved.")
  quit(status = 1)
}

metrics <- list(
  citations = as.integer(prof$total_cites),
  h_index   = as.integer(prof$h_index),
  i10_index = as.integer(prof$i10_index),
  updated   = format(Sys.Date(), "%Y-%m-%d")
)

yaml::write_yaml(metrics, "_metrics.yml")

cat(sprintf(
  "[update_metrics] OK. citations = %d  h-index = %d  i10 = %d  (updated %s)\n",
  metrics$citations, metrics$h_index, metrics$i10_index, metrics$updated
))

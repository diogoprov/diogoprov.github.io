# fetch_metrics.R --------------------------------------------------------
# Try to refresh assets/metrics.yml from public bibliometric sources.
#
# What is feasible without paid API access:
#   * Google Scholar   — scraped via the `scholar` package. Works most of
#                        the time; Scholar occasionally blocks requests.
#   * Web of Science   — REQUIRES an API key. The new "Researcher API"
#                        (https://developer.clarivate.com/apis) has a free
#                        tier; institutional access is the usual route.
#                        Set WOS_API_KEY in the environment.
#   * Scopus           — REQUIRES an Elsevier API key from
#                        https://dev.elsevier.com (free for non-commercial
#                        academic use, 5k requests/week). Set SCOPUS_API_KEY.
#
# When a key is missing or a fetch fails, the previous value in metrics.yml
# is kept. The script never silently zeros out a working number.
#
# Run from project root:  Rscript scripts/fetch_metrics.R
# ------------------------------------------------------------------------

suppressPackageStartupMessages({
  if (!requireNamespace("yaml",    quietly = TRUE)) install.packages("yaml")
  if (!requireNamespace("scholar", quietly = TRUE)) install.packages("scholar")
  library(yaml)
})

path  <- "assets/metrics.yml"
m     <- yaml::read_yaml(path)
SCHOLAR_ID <- "qDwcLvIAAAAJ"
SCOPUS_ID  <- "36142276300"
WOS_ID     <- "B-3704-2008"

say <- function(...) cat(format(Sys.time(), "[%H:%M:%S]"), ..., "\n")

# --- Google Scholar -----------------------------------------------------
try_scholar <- function() {
  p <- scholar::get_profile(SCHOLAR_ID)
  list(
    h_index         = as.integer(p$h_index),
    i10_index       = as.integer(p$i10_index),
    citations_total = as.integer(p$total_cites)
  )
}
res <- tryCatch(try_scholar(), error = function(e) { say("Scholar failed:", conditionMessage(e)); NULL })
if (!is.null(res)) {
  m$scholar$h_index         <- res$h_index
  m$scholar$i10_index       <- res$i10_index
  m$scholar$citations_total <- res$citations_total
  say("Scholar OK — h =", res$h_index, "| cites =", res$citations_total)
}

# --- Scopus -------------------------------------------------------------
# Key is read from the SCOPUS_API_KEY environment variable.
# Local Mac:     add  SCOPUS_API_KEY=xxxxxxxx  to ~/.Renviron and restart R.
# GitHub CI:     Settings → Secrets → Actions → new secret named SCOPUS_API_KEY.
# NEVER hardcode the key in this file — it goes public on push.
SCOPUS_KEY <- Sys.getenv("SCOPUS_API_KEY")
if (nzchar(SCOPUS_KEY)) {
  res <- tryCatch({
    url <- sprintf("https://api.elsevier.com/content/author/author_id/%s?view=METRICS", SCOPUS_ID)
    h   <- httr::add_headers("X-ELS-APIKey" = SCOPUS_KEY, "Accept" = "application/json")
    r   <- httr::GET(url, h)
    httr::stop_for_status(r)
    a   <- httr::content(r)$`author-retrieval-response`[[1]]
    list(
      h_index    = as.integer(a$`h-index`),
      citations  = as.integer(a$`coredata`$`citation-count`),
      papers     = as.integer(a$`coredata`$`document-count`)
    )
  }, error = function(e) { say("Scopus failed:", conditionMessage(e)); NULL })
  if (!is.null(res)) {
    m$scopus$h_index   <- res$h_index
    m$scopus$citations <- res$citations
    m$scopus$papers    <- res$papers
    say("Scopus OK — h =", res$h_index)
  }
} else {
  say("Scopus: SCOPUS_API_KEY not set — skipping.")
}

# --- Web of Science ------------------------------------------------------
# Disabled: the WoS Researcher API requires a Clarivate subscription that
# isn't available without institutional access. Update wos: values in
# assets/metrics.yml by hand if/when you have the numbers.
# (Block kept commented for future use if a key becomes available.)
# WOS_KEY <- Sys.getenv("WOS_API_KEY")
# if (nzchar(WOS_KEY)) { ... }
say("WoS: API requires subscription — edit metrics.yml manually if needed.")

m$last_checked <- format(Sys.Date(), "%B %Y")
yaml::write_yaml(m, path)
say("Wrote", path)

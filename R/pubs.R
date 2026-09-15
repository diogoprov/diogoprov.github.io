# pubs.R -------------------------------------------------------------------
# Render the publication lists from the single source of truth,
# data/publications.yml, into the two views the site needs.
#
#   pubs_list("peer_reviewed")  -> publications.qmd  (HTML view, with icons)
#   pubs_cv("articles")         -> cv.qmd            (numbered CV view)
#
# Never edit the generated lists in the .qmd files - edit the YAML.
# Usage inside a .qmd chunk:
#     ```{r}
#     #| echo: false
#     #| results: asis
#     source("R/pubs.R"); pubs_list("peer_reviewed")
#     ```
# ---------------------------------------------------------------------------

.pubs_data <- local({
  cache <- NULL
  function() {
    if (is.null(cache)) cache <<- yaml::read_yaml("data/publications.yml")
    cache
  }
})

# --- publications.qmd view -------------------------------------------------
# Reproduces the hand-written markup exactly: citation, then the verbatim
# icon/link row separated by " &nbsp;".
pubs_list <- function(section) {
  groups <- .pubs_data()[[section]]
  if (is.null(groups)) stop("Unknown section in publications.yml: ", section)
  out <- character(0)
  for (g in groups) {
    if (!is.null(g$year)) out <- c(out, paste0("### ", g$year))
    for (e in g$entries) {
      s <- e$cite
      if (!is.null(e$links_raw)) s <- paste0(s, " &nbsp;\n", e$links_raw)
      out <- c(out, s)
    }
  }
  cat(paste(out, collapse = "\n\n"), "\n")
  invisible(NULL)
}

# Counts for the metrics row (replaces the old regex-over-the-qmd hack).
pubs_count <- function(section) {
  sum(vapply(.pubs_data()[[section]], function(g) length(g$entries), integer(1)))
}

# --- cv.qmd view -----------------------------------------------------------
# The CV differs from the web view in only three ways:
#   1. a "[N]" prefix, numbered ascending by date but printed newest first
#   2. spaces between author initials  ("P.M." -> "P. M.")
#   3. the DOI as a markdown link instead of an icon
.space_initials <- function(x) gsub("([A-Z]\\.)(?=[A-Z]\\.)", "\\1 ", x, perl = TRUE)

.first_doi <- function(e) {
  if (is.null(e$links_raw)) return(NULL)
  m <- regmatches(e$links_raw, regexpr("10\\.[0-9]{4,9}/[^\"<> ]+", e$links_raw))
  if (length(m)) sub("[.,;]$", "", m) else NULL
}

pubs_cv <- function(which = "articles", section = "peer_reviewed") {
  groups <- .pubs_data()[[section]]
  sel <- list()
  for (g in groups) for (e in g$entries) {
    if (identical(e$cv, which)) sel[[length(sel) + 1L]] <- e
  }
  n <- length(sel)                    # YAML is newest-first; oldest paper is [1]
  out <- character(0)
  for (i in seq_along(sel)) {
    e <- sel[[i]]
    cite <- .space_initials(gsub("\n", " ", e$cite))
    cite <- sub("^\\[(Editorial|Commentary)\\]\\s*", "", cite)
    doi <- .first_doi(e)
    if (!is.null(doi)) cite <- paste0(cite, " [doi:", doi, "](https://doi.org/", doi, ")")
    out <- c(out, sprintf("[%d] %s", n - i + 1L, cite))
  }
  cat(paste(out, collapse = "\n\n"), "\n")
  invisible(NULL)
}

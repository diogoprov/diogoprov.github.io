# pubs.R -------------------------------------------------------------------
# Render the publication lists from the single source of truth,
# data/publications.yml, into the two views the site needs.
#
#   pubs_list("peer_reviewed")  -> publications.qmd  (HTML view, with icons)
#   pubs_cv("articles")         -> cv.qmd            (numbered CV view)
#
# Both publications.qmd and cv.qmd read this data; citations are edited once.
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
    if (is.null(cache)) {
      data <- yaml::read_yaml("data/publications.yml")
      validate_publications(data)
      cache <<- data
    }
    cache
  }
})

# --- publications.qmd view -------------------------------------------------
# Reproduces the hand-written markup exactly: citation, then the verbatim
# icon/link row separated by " &nbsp;".
# toc = FALSE keeps the year headings out of the page's table of contents.
pubs_list <- function(section, toc = FALSE) {
  groups <- .pubs_data()[[section]]
  if (is.null(groups)) stop("Unknown section in publications.yml: ", section)
  out <- character(0)
  for (g in groups) {
    if (!is.null(g$year)) {
      out <- c(out, paste0("### ", g$year,
                           if (toc) paste0(" {#", gsub("_", "-", section), "-", g$year, "}")
                           else " {.unlisted}"))
    }
    for (e in g$entries) {
      s <- e$cite
      if (!is.null(e$links_raw)) s <- paste0(s, " &nbsp;\n", e$links_raw)
      if (!is.null(e$doi) && !grepl(e$doi, s, fixed = TRUE))
        s <- paste0(s, " [doi:", e$doi, "](https://doi.org/", e$doi, ")")
      if (!is.null(e$note)) s <- paste0(s, "\n\n", e$note)
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
# The CV adds section numbering, spaces between author initials, readable
# links, and shared featured-paper/authorship metadata. Cite text is not copied.
.space_initials <- function(x) gsub("([A-Z]\\.)(?=[A-Z]\\.)", "\\1 ", x, perl = TRUE)

.first_doi <- function(e) {
  if (!is.null(e$doi)) return(e$doi)
  if (is.null(e$links_raw)) return(NULL)
  # Dataset and preprint DOIs must not become the journal article's DOI.
  html <- gsub("\n", " ", e$links_raw)
  anchors <- regmatches(html, gregexpr('<a\\s[^>]*>.*?</a>', html, perl = TRUE))[[1]]
  anchors <- anchors[!grepl('title="[^"]*(Data|Preprint)', anchors, ignore.case = TRUE)]
  html <- paste(anchors, collapse = " ")
  m <- regmatches(html, regexpr("10\\.[0-9]{4,9}/[^\"<> ]+", html))
  if (length(m)) sub("[.,;]$", "", m) else NULL
}

.cv_links <- function(e, doi) {
  links <- character()
  if (!is.null(doi)) links <- paste0("[doi:", doi, "](https://doi.org/", doi, ")")
  if (is.null(e$links_raw)) return(links)
  html <- gsub("\n", " ", e$links_raw)
  anchors <- regmatches(html, gregexpr('<a\\s[^>]*>.*?</a>', html, perl = TRUE))[[1]]
  for (a in anchors) {
    url <- sub('.*?href="([^"]+)".*', '\\1', a, perl = TRUE)
    if (!grepl('href="', a, fixed = TRUE)) next
    if (!is.null(doi) && grepl(doi, url, fixed = TRUE)) next
    label <- if (grepl('title="', a, fixed = TRUE))
      sub('.*?title="([^"]+)".*', '\\1', a, perl = TRUE) else "Link"
    links <- c(links, paste0("[", label, "](", gsub("&amp;", "&", url, fixed = TRUE), ")"))
  }
  unique(links)
}

pubs_cv <- function(which = "articles", section = "peer_reviewed", numbered = TRUE) {
  groups <- .pubs_data()[[section]]
  sel <- list()
  for (g in groups) for (e in g$entries) {
    if (!identical(e$cv, "skip") && (is.null(which) || identical(e$cv, which)))
      sel[[length(sel) + 1L]] <- e
  }
  n <- length(sel)                    # YAML is newest-first; oldest paper is [1]
  out <- character(0)
  for (i in seq_along(sel)) {
    e <- sel[[i]]
    cite <- .space_initials(gsub("\n", " ", e$cite))
    cite <- sub("^\\[(Editorial|Commentary)\\]\\s*", "", cite)
    cite <- gsub("\\^([^\\^]+)\\^", " — *\\1*", cite, perl = TRUE)
    doi <- .first_doi(e)
    links <- .cv_links(e, doi)
    if (length(links)) cite <- paste(cite, paste(links, collapse = " · "))
    if (!is.null(e$cv_note)) cite <- paste0(cite, " — ", e$cv_note)
    if (!is.null(e$note)) cite <- paste0(cite, "\n\n", e$note)
    key <- if (numbered) sprintf("[%d] ", n - i + 1L) else ""
    if (isTRUE(e$featured)) {
      key <- if (numbered) sprintf('<span class="cv-pub-key">[%d]</span> ', n - i + 1L) else ""
      cite <- paste0("::: {.cv-pub-featured}\n", key, cite, "\n:::")
    } else cite <- paste0(key, cite)
    out <- c(out, cite)
  }
  cat(paste(out, collapse = "\n\n"), "\n")
  invisible(NULL)
}

# Fail before either view renders if the shared bibliography is malformed.
validate_publications <- function(data) {
  sections <- c("peer_reviewed", "books", "book_chapters", "in_press", "in_review", "in_preparation")
  scalar_text <- function(x) is.character(x) && length(x) == 1L && !is.na(x) && nzchar(trimws(x))
  if (!is.list(data) || !all(sections %in% names(data)))
    stop("Missing publication sections: ", paste(setdiff(sections, names(data)), collapse = ", "))
  seen_cites <- seen_dois <- character()
  for (section in sections) {
    groups <- data[[section]]
    if (!is.list(groups) || !length(groups)) stop("Empty publication section: ", section)
    for (g in groups) {
      if (!is.list(g) || !"year" %in% names(g) ||
          (!is.null(g$year) && !grepl("^[0-9]{4}$", as.character(g$year))))
        stop("Invalid year in ", section)
      if (!is.list(g$entries) || !length(g$entries)) stop("Missing entries in ", section)
      for (e in g$entries) {
        if (!is.list(e) || !scalar_text(e$cite)) stop("Missing citation in ", section)
        if (!scalar_text(e$cv) || !e$cv %in% c("articles", "editorials", "skip"))
          stop("Invalid CV category in ", section, ": ", substr(e$cite, 1, 80))
        for (field in c("doi", "note", "cv_note", "links_raw"))
          if (!is.null(e[[field]]) && !scalar_text(e[[field]])) stop("Invalid ", field, " in ", section)
        if (!is.null(e$featured) && (!is.logical(e$featured) || length(e$featured) != 1L || is.na(e$featured)))
          stop("featured must be true or false in ", section)
        key <- tolower(gsub("[[:space:][:punct:]]", "", e$cite))
        if (key %in% seen_cites) stop("Duplicate citation in ", section, ": ", substr(e$cite, 1, 80))
        seen_cites <- c(seen_cites, key)
        doi <- .first_doi(e)
        if (!is.null(doi)) {
          if (!scalar_text(doi) || !grepl("^10\\.[0-9]{4,9}/[^[:space:]]+$", doi)) stop("Invalid DOI in ", section)
          if (tolower(doi) %in% seen_dois) stop("Duplicate DOI: ", doi)
          seen_dois <- c(seen_dois, tolower(doi))
        }
      }
    }
  }
  invisible(TRUE)
}

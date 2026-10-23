source("R/pubs.R")
data <- .pubs_data()
stopifnot(isTRUE(validate_publications(data)))
rejected <- function(change) {
  bad <- change(data)
  stopifnot(inherits(try(validate_publications(bad), silent = TRUE), "try-error"))
}
rejected(function(d) { d$books <- NULL; d })
rejected(function(d) { d$peer_reviewed[[1]]$entries[[1]]$cite <- ""; d })
rejected(function(d) { d$peer_reviewed[[1]]$entries[[1]]$cv <- "unknown"; d })
rejected(function(d) { d$peer_reviewed[[1]]$entries[[1]]$featured <- "yes"; d })
rejected(function(d) { d$peer_reviewed[[1]]$year <- "soon"; d })
rejected(function(d) {
  d$in_review[[1]]$entries <- c(d$in_review[[1]]$entries, d$in_review[[1]]$entries[1])
  d
})
rejected(function(d) {
  d$in_review[[1]]$entries[[1]]$doi <- d$peer_reviewed[[1]]$entries[[1]]$doi
  d
})
rejected(function(d) { d$in_review[[1]]$entries[[1]]$doi <- "invalid DOI"; d })

articles <- paste(capture.output(pubs_cv()), collapse = "\n")
stopifnot(length(gregexpr('::: {.cv-pub-featured}', articles, fixed = TRUE)[[1]]) == 3L,
          grepl(".underline", articles, fixed = TRUE),
          grepl("Featured in F1000 Prime", articles, fixed = TRUE),
          grepl("joint senior authors", articles, fixed = TRUE),
          !grepl("Challenges and strategies to teach history", articles, fixed = TRUE),
          !grepl("^", articles, fixed = TRUE))
stopifnot(is.null(.first_doi(list(links_raw =
  '<a href="https://doi.org/10.1234/dataset" title="Data">Data</a>'))))

# A newly added entry reaches both views without editing either document.
test_env <- new.env(parent = globalenv())
sys.source("R/pubs.R", test_env)
data$in_press[[1]]$entries <- c(list(list(
  cv = "articles", cite = "Example, A. 2027. A newly accepted paper.",
  doi = "10.1234/new-paper"
)), data$in_press[[1]]$entries)
test_env$.pubs_data <- function() data
web <- paste(capture.output(test_env$pubs_list("in_press")), collapse = "\n")
cv <- paste(capture.output(test_env$pubs_cv(NULL, "in_press", numbered = FALSE)), collapse = "\n")
stopifnot(grepl("A newly accepted paper", web, fixed = TRUE),
          grepl("A newly accepted paper", cv, fixed = TRUE),
          grepl("https://doi.org/10.1234/new-paper", web, fixed = TRUE),
          grepl("https://doi.org/10.1234/new-paper", cv, fixed = TRUE),
          !grepl("[1]", cv, fixed = TRUE))
cat("Publication schema, duplicate detection and shared CV generation checks passed.\n")

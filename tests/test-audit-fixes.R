# Run from the repository root: Rscript --vanilla tests/test-audit-fixes.R
source("R/metrics.R")
m <- list(
  scholar = list(h_index = 26L, i10_index = 45L, citations_total = 1851L,
                 last_success = "2026-06-01"),
  scopus = list(h_index = 19L, citations = 1126L, papers = 64L),
  wos = list(h_index = 18L)
)
today <- "2026-10-22"
failed <- refresh_metric_source(m, "scholar", function() stop("offline"), today)
stopifnot(identical(failed$scholar$last_success, m$scholar$last_success),
          identical(failed$scholar$citations_total, m$scholar$citations_total),
          identical(failed$scholar$last_attempt, today),
          identical(failed$scopus, m$scopus), identical(failed$wos, m$wos))
for (bad in list(NULL, NA_real_, Inf, -1, 1.5, numeric(), "27")) {
  result <- refresh_metric_source(m, "scholar", function() {
    list(h_index = bad, i10_index = 46, citations_total = 1900)
  }, today)
  stopifnot(identical(result, failed))
}
success <- refresh_metric_source(m, "scholar", function() {
  list(h_index = 27, i10_index = 46, citations_total = 1900)
}, today)
stopifnot(success$scholar$h_index == 27,
          identical(success$scholar$last_success, today),
          identical(success$scholar$last_attempt, today),
          identical(success$scopus, m$scopus),
          metric_success_date(m, "scopus") == "not recorded",
          metric_success_date(NULL, "scholar") == "not recorded")
zero <- refresh_metric_source(m, "scopus", function() {
  list(h_index = 0, citations = 0, papers = 0)
}, today)
stopifnot(zero$scopus$citations == 0, zero$scopus$last_success == today)

# Exercise stale HTML, render failures, Chrome failures and successful replacement.
build_source <- parse("scripts/build_cv_pdf.R")
env <- new.env(parent = globalenv())
eval(build_source[[1]], env)
env$requireNamespace <- function(...) TRUE
printed <- FALSE
print_pdf <- function(input, output, ...) {
  printed <<- TRUE
  writeChar("%PDF-test", output, eos = NULL)
}
env$`::` <- function(package, name) print_pdf
original_dir <- getwd()
scratch <- tempfile("cv-regression-")
dir.create(scratch)
setwd(scratch)
dir.create("docs")
dir.create("assets")
writeLines("old PDF", "assets/cv.pdf")
old_pdf <- readLines("assets/cv.pdf")
writeLines("stale HTML", "docs/cv.html")
env$system2 <- function(...) 1L
stopifnot(inherits(try(env$build_cv_pdf(), silent = TRUE), "try-error"),
          !printed, !file.exists("docs/cv.html"),
          identical(readLines("assets/cv.pdf"), old_pdf))
env$system2 <- function(...) 0L
stopifnot(inherits(try(env$build_cv_pdf(), silent = TRUE), "try-error"), !printed)
env$system2 <- function(...) { writeLines("new HTML", "docs/cv.html"); 0L }
print_pdf <- function(...) stop("Chrome failed")
stopifnot(inherits(try(env$build_cv_pdf(), silent = TRUE), "try-error"),
          identical(readLines("assets/cv.pdf"), old_pdf))
print_pdf <- function(input, output, ...) writeLines("invalid PDF", output)
stopifnot(inherits(try(env$build_cv_pdf(), silent = TRUE), "try-error"),
          identical(readLines("assets/cv.pdf"), old_pdf))
print_pdf <- function(input, output, ...) writeChar("%PDF-test", output, eos = NULL)
env$build_cv_pdf()
stopifnot(identical(readBin("assets/cv.pdf", "raw", 100),
                    readBin("docs/assets/cv.pdf", "raw", 100)),
          readChar("assets/cv.pdf", 5L) == "%PDF-")
setwd(original_dir)
unlink(scratch, recursive = TRUE)
cat("All audit regression checks passed.\n")

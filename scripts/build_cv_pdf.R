# build_cv_pdf.R ----------------------------------------------------------
# Re-render cv.qmd to PDF (assets/cv.pdf).
#
# Strategy: cv.qmd uses custom HTML divs (.cv-page, .cv-sidebar, etc.) plus
# CSS in assets/styles/cv.css. LaTeX cannot reproduce that layout, so we
# render the HTML first (via Quarto) and then "print" it to PDF using
# headless Chrome — the @media print rules in cv.css are honoured.
#
# Requires: quarto CLI, R packages pagedown (which uses chromote).
# Install once:  install.packages(c("pagedown", "chromote"))
#
# Usage from the project root:
#   Rscript scripts/build_cv_pdf.R
# -------------------------------------------------------------------------

build_cv_pdf <- function() {
  stopifnot(requireNamespace("pagedown", quietly = TRUE))
  html_in <- "docs/cv.html"
  pdf_out <- "assets/cv.pdf"

  # Require HTML produced by this invocation, never a previous render.
  if (file.exists(html_in) && !file.remove(html_in))
    stop("Could not remove stale ", html_in)
  message("Rendering cv.qmd …")
  status <- system2("quarto", c("render", "cv.qmd"), stdout = "", stderr = "")
  if (status != 0L)
    stop("quarto render cv.qmd failed with exit status ", status)
  if (!file.exists(html_in))
    stop("Expected ", html_in, " after quarto render.")

  # Keep the existing PDF intact unless Chrome produces a valid replacement.
  pdf_tmp <- tempfile("cv-", tmpdir = dirname(pdf_out), fileext = ".pdf")
  on.exit(unlink(pdf_tmp), add = TRUE)
  message("Printing to PDF …")
  pagedown::chrome_print(
    input = html_in,
    output = pdf_tmp,
    format = "pdf",
    options = list(
      printBackground = TRUE,
      preferCSSPageSize = TRUE,
      marginTop = 0, marginBottom = 0,
      marginLeft = 0, marginRight = 0
    )
  )
  if (!file.exists(pdf_tmp) || file.info(pdf_tmp)$size < 5L ||
      !identical(readChar(pdf_tmp, 5L, useBytes = TRUE), "%PDF-"))
    stop("Chrome did not produce a valid PDF.")
  if (!file.rename(pdf_tmp, pdf_out))
    stop("Could not replace ", pdf_out)

  # Also refresh the served copy when this script is run after a full render.
  docs_copy <- file.path("docs", pdf_out)
  dir.create(dirname(docs_copy), recursive = TRUE, showWarnings = FALSE)
  if (!file.copy(pdf_out, docs_copy, overwrite = TRUE))
    stop("Could not refresh ", docs_copy)

  # The post-render validator checks this invocation and the exact source/PDF
  # hashes, so an old committed PDF cannot satisfy the deployment checks.
  inputs <- c("cv.qmd", "data/publications.yml", "R/pubs.R", "R/metrics.R",
              "assets/metrics.yml", "assets/styles/cv.css", "styles.css",
              "_quarto.yml", "scripts/build_cv_pdf.R")
  hashes <- tools::md5sum(inputs)
  if (anyNA(hashes)) stop("Missing CV source inputs.")
  dir.create(".quarto", showWarnings = FALSE)
  jsonlite::write_json(list(
    build_id = Sys.getenv("SITE_BUILD_ID", unset = "local"),
    pdf_md5 = unname(tools::md5sum(pdf_out)),
    source_hashes = as.list(hashes)
  ), ".quarto/cv-build.json", auto_unbox = TRUE, pretty = TRUE)
  message("Wrote ", pdf_out, " and refreshed ", docs_copy)
}

build_cv_pdf()

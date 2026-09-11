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

stopifnot(requireNamespace("pagedown", quietly = TRUE))

# 1. Render the site (or just cv.qmd) so docs/cv.html is up to date
message("Rendering cv.qmd …")
system2("quarto", c("render", "cv.qmd"), stdout = "", stderr = "")

html_in <- "docs/cv.html"
pdf_out <- "assets/cv.pdf"

if (!file.exists(html_in))
  stop("Expected ", html_in, " after `quarto render` — check the build log.")

# 2. Print to PDF via headless Chrome. `format = "pdf"` honours @media print.
message("Printing to PDF …")
pagedown::chrome_print(
  input  = html_in,
  output = pdf_out,
  format = "pdf",
  options = list(
    printBackground   = TRUE,         # keep the dark sidebar colour
    preferCSSPageSize = TRUE,         # respect @page A4 from cv.css
    marginTop = 0, marginBottom = 0,  # margins already set in @page
    marginLeft = 0, marginRight = 0
  )
)

message("Wrote ", pdf_out, " (", file.info(pdf_out)$size %/% 1024, " KB).")

# 3. GitHub Pages serves the site from docs/, so https://provetelab.org/assets/cv.pdf
#    is docs/assets/cv.pdf -- NOT the copy at the repo root. `quarto render` only
#    copies assets/ into docs/ while it runs, so a PDF built afterwards would be
#    left behind and the site would keep serving the previous version. Refresh the
#    served copy here so the build order stops mattering.
docs_copy <- file.path("docs", pdf_out)
if (dir.exists(dirname(docs_copy))) {
  file.copy(pdf_out, docs_copy, overwrite = TRUE)
  message("Refreshed ", docs_copy, " (the copy the site actually serves).")
} else {
  warning(dirname(docs_copy), " not found - run `quarto render` once, then re-run this script.")
}

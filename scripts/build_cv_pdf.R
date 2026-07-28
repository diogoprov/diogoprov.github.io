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

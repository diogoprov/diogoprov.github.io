# Biodiversity Synthesis Lab — website

Quarto website for the lab of **Diogo B. Provete** at the Instituto de
Biociências, Universidade Federal de Mato Grosso do Sul (UFMS).

Live site: <https://provetelab.org/>

## Local build

Use **R 4.6.1** and **Quarto 1.8.26**, the versions used by CI. The
project's `renv.lock` pins the render dependencies and their transitive
dependencies; `renv/activate.R` pins renv itself. `DESCRIPTION` lists the
direct build dependencies (`Imports`). Restore them before rendering:

Copy `.Renviron.example` to `.Renviron` if you need project-local settings.
The example enables renv and documents the optional Scopus API key. Keep real
credentials in the ignored `.Renviron` or in GitHub Actions secrets.

```bash
export RENV_CONFIG_AUTOLOADER_ENABLED=TRUE
Rscript -e 'renv::restore(prompt = FALSE, retry = FALSE)'
```

If a local `.Renviron` sets `RENV_CONFIG_AUTOLOADER_ENABLED=FALSE`, remove
that line or change it to `TRUE`; R reads that file after the shell
environment. For a complete build with deployment checks:

```bash
quarto preview     # live reload on http://localhost:4200
Rscript scripts/build_cv_pdf.R
quarto render
python3 scripts/validate_site.py
```

Python 3.9+ is required for the offline validator (standard library only).
To deliberately update build dependencies, edit `DESCRIPTION`, install the
chosen versions with `renv::install()`, then run
`renv::snapshot(type = "explicit", dev = FALSE)` and commit the lockfile.
Update the R/Quarto pins in the workflow together with any tool upgrade.

## Deployment

The site is built and published by GitHub Actions
(`.github/workflows/render-cv.yml`) on every push to `main`; GitHub Pages is
configured with Source = "GitHub Actions". The rendered `docs/` directory is
**not** committed (it is in `.gitignore`), so publishing a change is just:
edit the `.qmd`, commit, push. Pull requests are rendered but not deployed.
Builds have read-only repository access; only the deploy job receives Pages
and OIDC write permissions. PR runs have a separate concurrency group per PR;
new commits cancel that PR's obsolete build, while publication runs are serialized.

The workflow also rebuilds `assets/cv.pdf` from `cv.qmd`
(`scripts/build_cv_pdf.R`) before rendering. A failed CV rebuild stops deployment;
the workflow does not publish the previous PDF as a fallback.

Before uploading the Pages artifact, CI checks all rendered pages and local
links (including downloads and anchors), required outputs, titles, viewport
metadata and page languages. Course pages inherit `lang: pt-BR` from
`teaching/_metadata.yml`; the rest of the site uses English. CV verification
requires a build-specific manifest with hashes of the PDF and its source
inputs, preventing a previous PDF from satisfying a new deployment.

## Project layout

```
.
├── _quarto.yml         # site config (navbar, theme, output dir)
├── styles.css          # custom CSS (hero, people cards, navbar tweaks)
├── index.qmd           # home page (welcome text + latest news)
├── research.qmd        # research lines
├── publications.qmd    # peer-reviewed articles, books, chapters, abstracts
├── people.qmd          # current + past members
├── teaching.qmd        # courses and short-courses (course pages in teaching/)
├── talks.qmd           # invited talks (slides in talks/)
├── opportunities.qmd   # message for prospective students + resources
├── projects.qmd        # funded projects
├── software.qmd        # CoDa Stereo and other tools the lab maintains
├── cv.qmd              # CV page (also rendered to assets/cv.pdf)
├── news/               # lab news (listing on the home page)
├── data/               # publications.yml (source of the publication lists)
├── R/                  # pubs.R (renders data/publications.yml)
├── scripts/            # fetch_metrics.R, build_cv_pdf.R, compress_slides.sh
└── assets/             # images, files (PDFs, CV), metrics.yml
```

## Adding content

- **News post:** create `news/YYYY-MM-DD-slug/index.qmd` with `date:` in the
  YAML front-matter. The home page listing picks it up automatically.
- **New publication:** edit `data/publications.yml` — `publications.qmd`
  and the publication sections of `cv.qmd` both render from it via `R/pubs.R`.
  Do not edit citations in the CV. Required fields are `cite` and `cv`
  (`articles`, `editorials`, or `skip`); groups have a four-digit `year`
  or `null`. Optional `doi`, `featured`, and `cv_note` fields preserve DOI
  links, highlighted papers, and CV authorship/award notes. Validation rejects
  incomplete records, invalid categories and duplicate citations or DOIs.
  Conference abstracts and the thesis remain in `publications.qmd`.
- **Citation metrics:** `Rscript scripts/fetch_metrics.R` refreshes
  `assets/metrics.yml`, which both `publications.qmd` and `cv.qmd` read.
  Each source records `last_attempt` and `last_success` separately (ISO dates).
  Failed or incomplete responses preserve the previous values and success date.
  For manual WoS updates, also set `wos.last_success` to the verification date.
  `legacy_last_checked` preserves the old shared date, whose source-specific
  success dates are unknown.
  The optional refresh tools are not needed by CI: install them explicitly
  with `renv::install(c("scholar@1.0.0", "httr@1.4.9"))` when refreshing metrics.
  Keep these optional tools out of the render lockfile (`dev = FALSE`).
- **New software:** add a new `##` section to `software.qmd` following the
  CoDa Stereo template (callout-tip with links, description, features
  table, install snippet, citation).

## Regression checks

```bash
export RENV_CONFIG_AUTOLOADER_ENABLED=TRUE
Rscript tests/test-audit-fixes.R
Rscript tests/test-publications.R
python3 -m unittest discover -s tests -p 'test_*.py'
```

These offline checks cover metric refresh failures, invalid responses, CV
render/printing failures, bibliography validation, and deployment checks for
broken links, languages, metadata and stale or truncated CV PDFs.

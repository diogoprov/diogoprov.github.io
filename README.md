# Biodiversity Synthesis Lab — website

Quarto website for the lab of **Diogo B. Provete** at the Instituto de
Biociências, Universidade Federal de Mato Grosso do Sul (UFMS).

Live site: <https://provetelab.org/>

## Local build

```bash
quarto preview     # live reload on http://localhost:4200
quarto render      # one-shot build into docs/
```

## Deployment

The site is built and published by GitHub Actions
(`.github/workflows/render-cv.yml`) on every push to `main`; GitHub Pages is
configured with Source = "GitHub Actions". The rendered `docs/` directory is
**not** committed (it is in `.gitignore`), so publishing a change is just:
edit the `.qmd`, commit, push. Pull requests are rendered but not deployed.

The workflow also rebuilds `assets/cv.pdf` from `cv.qmd`
(`scripts/build_cv_pdf.R`) before rendering.

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
├── assets/             # images, files (PDFs, CV), metrics.yml
└── _archive_alban_template/   # old scaffold kept for reference
```

## Adding content

- **News post:** create `news/YYYY-MM-DD-slug/index.qmd` with `date:` in the
  YAML front-matter. The home page listing picks it up automatically.
- **New publication:** edit `data/publications.yml` — `publications.qmd`
  renders its lists from it via `R/pubs.R` (conference abstracts are still
  written in `publications.qmd`). Then add articles to the publication list
  of `cv.qmd`, which is still hand-edited.
- **Citation metrics:** `Rscript scripts/fetch_metrics.R` refreshes
  `assets/metrics.yml`, which both `publications.qmd` and `cv.qmd` read.
- **New software:** add a new `##` section to `software.qmd` following the
  CoDa Stereo template (callout-tip with links, description, features
  table, install snippet, citation).

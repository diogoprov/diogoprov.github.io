# Biodiversity Synthesis Lab — website

Quarto website for the lab of **Diogo B. Provete** at the Instituto de
Biociências, Universidade Federal de Mato Grosso do Sul (UFMS).

Live site: <https://diogoprov.github.io/>

## Local build

```bash
quarto preview     # live reload on http://localhost:4200
quarto render      # one-shot build into docs/
```

## Deployment

GitHub Pages is configured to serve from the `docs/` directory on the default
branch. After editing content, run `quarto render` and push the resulting
changes (including `docs/`).

## Project layout

```
.
├── _quarto.yml         # site config (navbar, theme, output dir)
├── styles.css          # custom CSS (hero, people cards, navbar tweaks)
├── index.qmd           # home page (hybrid: top bar + Hugo Academic hero)
├── research.qmd        # research lines
├── publications.qmd    # peer-reviewed articles, books, chapters
├── people.qmd          # current + past members
├── teaching.qmd        # courses and short-courses
├── opportunities.qmd   # message for prospective students + resources
├── projects.qmd        # funded projects
├── software.qmd        # CoDaStereo and other tools the lab maintains
├── news/               # lab news (listing on the home page)
├── assets/             # images, files (PDFs, CV)
└── _archive_alban_template/   # old scaffold kept for reference
```

## Adding content

- **News post:** create `news/YYYY-MM-DD-slug/index.qmd` with `date:` in the
  YAML front-matter. The home page listing picks it up automatically.
- **New publication:** edit `publications.qmd` directly (it's hand-curated to
  preserve formatting, links, and awards).
- **New software:** add a new `##` section to `software.qmd` following the
  CoDa Stereo template (callout-tip with links, description, features
  table, install snippet, citation).

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
├── cv.qmd              # dynamic CV (listing of posts tagged "experience")
├── posts/              # blog/CV entries (each post is a folder with index.qmd)
├── news/               # lab news (listing on the home page)
├── assets/             # images, files (PDFs, CV)
└── _archive_alban_template/   # old scaffold kept for reference
```

## Adding content

- **News post:** create `news/YYYY-MM-DD-slug/index.qmd` with `date:` in the
  YAML front-matter. The home page listing picks it up automatically.
- **CV experience entry:** create `posts/YYYY-MM-DD-slug/index.qmd` with
  `categories: [experience]` in the YAML — it will appear on `cv.qmd`.
- **New publication:** edit `publications.qmd` directly (it's hand-curated to
  preserve formatting, links, and awards).

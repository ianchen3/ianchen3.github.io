# Personal website

A [Quarto](https://quarto.org) website.

Math uses the `math.sty`/`stat.sty` macros from [latex-styles](https://github.com/IanChenUIUC/latex-styles), rendered by MathJax.

## Layout

Everything whose name starts with `_` or `.` is managed by Quarto or other tools, except
`_quarto.yml` and `_metadata.yml`. Everything else is hand-written.

```
_quarto.yml                site config: navbar, footer, theme, filters
styles.scss                CSS on top of the light and dark themes
index.qmd                  about page                       /
blog/                      posts, and the listing in index.qmd   /blog/<slug>
publications/              papers, one listing per category      /publications/<slug>
  refs.bib                 BibTeX for every paper (also served for download)
  _metadata.yml            points every page in the folder at refs.bib
talks/  teaching/  notes/  entries, and the listing in index.qmd
news/                      news log                              /news/
  news.yml                 one item per line of news; the home page shows the latest three
files/                     everything that is not a page            /files/…
  site/                    favicon and other site-wide files
  personal/                avatar, CV
  <section>/<slug>/        files for one entry, e.g. files/talks/<slug>/slides.pdf
filters/                   Lua filters and shortcodes used by the site
sty/                       latex-styles checkout (pages branch)

_site/                     rendered site; not committed
_freeze/                   stored output of executed code; committed
_extensions/               extensions installed with `quarto add`; committed
.quarto/                   cache; not committed
```

The slug is the file name without `.qmd`, and it is the page's URL:
`talks/2025-05-06-magus.qmd` is served at `/talks/2025-05-06-magus`. A publication's slug is its BibTeX
key.

## Workflow

```sh
quarto preview      # serve locally; re-renders a page when it is saved
quarto render       # render the whole site into _site/
```

`quarto preview` re-renders only the pages that change. After editing `_quarto.yml`, a listing,
or a filter, restart it or run `quarto render`.

The footer date ("Site last updated") is the date the page was rendered, so a full render or
publish sets it on every page.

Code in executable pages runs once and its output is stored in `_freeze/`. A full render reuses
the stored output unless the page's source changed; rendering a single page always runs its code.

## Adding content

Each entry is one `.qmd` file in its section folder. Files that belong to it go in
`files/<section>/<slug>/` and are linked with root paths, e.g.
`[Slides](/files/talks/<slug>/slides.pdf)`.

Listings show `title`, `subtitle`, `date` and `description`. The `description` is the summary on
the listing and in the page header; it is not repeated in the body.

**Blog post** — `blog/<slug>.qmd`:

```yaml
---
title: "…"
description: "One-sentence summary."
date: 2026-11-05
categories: [algorithms]
---
```

Every post needs a `description`: without one, the listing cuts an excerpt from the first
paragraph, and a cut inside a formula leaves raw TeX.

**Talk, teaching, notes** — `talks/<slug>.qmd` (likewise `teaching/`, `notes/`):

```yaml
---
title: "…"
subtitle: "Presentation · Venue · City, State, Country"
date: 2025-12-01
description: "Abstract."
---

[Slides](/files/talks/<slug>/slides.pdf)
```

A course or group with several notes is a folder: `notes/<slug>/index.qmd` is its entry in the notes
listing and lists the pages beside it, as in `notes/fa26-cs421/`. The pages share a `subtitle`, which
is added to the `exclude` list in `notes/index.qmd` to keep them out of the main listing. Blog
series and talk series work the same way, as in `blog/mindbenders/` and `talks/sigma/`.

**Publication** — add the entry to `publications/refs.bib`, then `publications/<slug>.qmd`:

```yaml
---
title: "…"
subtitle: "Venue"
date: 2025-12-09
category: conferences          # manuscripts | conferences | preprints
description: "Authors."
nocite: "@bibkey"
---

[PDF](/files/publications/<slug>/paper.pdf){.btn .btn-outline-secondary .btn-sm}
[DOI](https://doi.org/…){.btn .btn-outline-secondary .btn-sm}

## Abstract

…
```

The entry's BibTeX source follows the abstract.

**News** — add an item to `news/news.yml`. The title is Markdown. The home page shows the same items,
so links to pages on the site start with `/`:

```yaml
- date: 2025-12-01
  title: "Gave a [talk](/talks/sigma/2025-12-01-kkt.qmd) at SIGma on linear-time MSTs."
```

## Math

Inline math is `$…$` and display math is `$$…$$`. The macros of `sty/math.sty` and
`sty/stat.sty` work as in LaTeX, as do the physics2 `\ab`, `\abs`, `\norm`, `\eval` and the
derivative package's `\odv`, `\pdv`, `\odif`, `\pdif`. Theorem environments are divs:

```markdown
::: {.thrm title="Bias-variance"}
$\MSE(\hat\theta) = \Var(\hat\theta) + \Bias(\hat\theta)^2$.
:::
```

The environments are `defn`, `ex`, `thrm`, `prop`, `lem`, `cor`, `exercise` and `pf`. They are
unnumbered, as in `math.sty`. For numbered theorems that can be cross-referenced, use Quarto's
own syntax, `::: {#thm-label}` with the title as a `##` heading, referenced as `@thm-label`.

## Filters

- `sty/quarto/html-adapter.lua`: renders what MathJax cannot (`\inferrule`, the `bnf`
  environment) with LaTeX and inlines it as SVG. Needs `latex` and `dvisvgm`; the SVGs are cached
  in `~/.cache/latex-styles-svg`, so LaTeX runs only for new or changed snippets.
- `sty/quarto/target-mathjax.lua`: expands the latex-styles macros for MathJax and renders the
  theorem divs.
- `filters/x-ocaml.lua`: turns ```` ```{.ocaml .live} ```` blocks into OCaml editors that run in
  the browser.
- `filters/bibtex.lua`: appends the BibTeX source of a page's `nocite` entries.
- `filters/today.lua`: the `{{< today >}}` shortcode used in the footer.

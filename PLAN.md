# Migrating Pages from Jekyll (academicpages) to a Quarto website

## Purpose

- Write site content with the latex-styles macros (`math.sty`, `stat.sty`, `plang.sty`) and
  theorem environments, rendered through the same Quarto filters the courses use.
- Get literate programming per post: knitr (R, bash, Rcpp, `exec`, …) or Jupyter (OCaml, Python),
  chosen per document, with results frozen.
- Live code: on pages that opt in, readers edit and run R, Python and OCaml in the page, using
  in-browser runtimes (no server). Frozen output stays the default everywhere else.
- Code blocks look like the `code.sty` boxes for every language `code.sty` defines, in static
  blocks and live cells alike.
- Drop the academicpages machinery that is not used: Ruby/gems, vendored Sass, Liquid pages, the
  generated CV, the talk map, portfolio and template sample pages.
- Keep all current content, except the LaTeXML notes page (`_notes/sp25-math427.md`), the RL post
  and its notes (`_posts/2025-05-16-rl.md`, `files/2024-summer-rl/`) and the resume
  (`files/Ian_Chen_Resume.pdf`), which are dropped. Old URLs are not kept.

The infrastructure is built and checked in the test site `~/src/test_pages` (sample content
only); the migration copies it over and converts the content. Its `README.md` documents the layout
and authoring conventions, and becomes the site's README.

Out of scope for the migration: converting existing posts to executable or live code, remote
runners (Compiler Explorer, Binder), visual design beyond the default themes and the `code.sty`
look.

## Settled

| Decision       | Choice |
|---             |---     |
| Domain         | `https://ianchen3.github.io` |
| Generator      | Quarto website (`project: type: website`), Quarto 1.10.18 |
| Look           | Themes `default` (light) and `darkly` (dark), following the reader's colour scheme; `styles.scss` on top. Home page is `about: template: solana` with the latest three news items. The academicpages look is not kept. |
| Layout         | `blog/ publications/ talks/ teaching/ notes/ news/`, each with its listing in `index.qmd`; a page's URL is its file path (`blog/<slug>.qmd` → `/blog/<slug>`). Files that are not pages live in `files/site/`, `files/personal/` and `files/<section>/<slug>/`. |
| URLs           | Old URLs break: no aliases, no redirect stubs, no copies at old file paths. The generated-CV pages (`/cv/`, `/cv-json/`, `/resume*.html`) and `/feed.xml` are dropped; the blog feed is `/blog/index.xml`. |
| Math           | MathJax. In `sty/quarto/`, `frontend.lua` rewrites math into standard LaTeX shared by every target; `target-mathjax.lua` and `target-typst.lua` hand it to MathJax and to pandoc's Typst writer, each with a short fix-up list. Layout constructs (`\inferrule`, `bnf`) have one filter per target: `html-adapter.lua` renders them with `latex-svg.lua` (`latex` + `dvisvgm`, inline SVG that follows the text colour, cached in `~/.cache/latex-styles-svg`), and `typst-adapter.lua` translates them to Typst packages. |
| Theorems       | `.thrm`, `.defn`, … divs render unnumbered, as in `math.sty`. Numbered, cross-referenced theorems use Quarto's own `::: {#thm-…}` syntax (Quarto numbers every built-in theorem). |
| `sty`          | git submodule of `git@github.com:IanChenUIUC/latex-styles.git` at `sty/`, following its own branch `pages`. |
| Deploy         | `quarto publish gh-pages` from the local machine (which has TeX, `dvisvgm` and the SVG cache); Pages serves the `gh-pages` branch. No CI. |
| Listings       | Every entry has a `description:` (an automatic excerpt can cut through a formula and show raw TeX). Listings show no thumbnails. |
| Publications   | `publications/refs.bib` is the only BibTeX file: `~/src/resume/refs.bib` without the fields meant for the CV (`author+an`, `keywords`, `tldr`, `abstract`); each page cites its entry with `nocite:`, and `filters/bibtex.lua` appends the BibTeX source. A paper is named by its BibTeX key (`vu-le2025using`): `publications/<key>.qmd` and `files/publications/<key>/paper.pdf`. Categories: manuscripts, conferences, preprints (no Books category while there is no book). |
| News           | `news/news.yml`, one item per line of news, with the title in Markdown and any links written in it; rendered by the custom template `news/news.ejs`. |
| Executable code | Per document: knitr, or `jupyter: ocaml-jupyter` (toplevel state across cells). `execute: freeze: auto`; `_freeze/` is committed. |
| Live code      | Opted into per page, runtimes loaded from their CDNs. R and Python: [quarto-live](https://github.com/r-wasm/quarto-live) (`format: live-html`, `{webr}`/`{pyodide}` cells, run on click). OCaml: [x-ocaml](https://github.com/art-w/x-ocaml) via `filters/x-ocaml.lua`, which turns ```` ```{.ocaml .live} ```` blocks into `<x-ocaml>` editors (run on load; script loaded with `defer`). Live demos are ordinary posts. HTML options are set at the top level of `_quarto.yml` so `live-html` pages get the theme and filters. |
| Sample pages   | None of the test site's sample pages move. |
| Grouped pages  | A course, group or series is a folder with one entry in its section's listing: `<section>/<slug>/index.qmd` lists the pages beside it (`notes/fa26-cs421/`, `notes/su26-reading/`, `blog/mindbenders/`, `talks/sigma/`, `talks/siam/`). |
| CS 421 notes   | `demos/09-24.qmd` and `demos/09-30.qmd` are live OCaml pages in `notes/fa26-cs421/`: `{ocaml}` cells become `{.ocaml .live}` blocks. |
| Code look      | Hand-written in `styles.scss` from the `code.sty` values: R, C++ and Python blocks get the `code.sty` box (background `black!2`, 2px left border in the language's colour, `filename=` as the title in small monospace at `black!70`); in dark mode white replaces black and the border colours stay. quarto-live editors get the same box. OCaml and other languages keep Quarto's default style. x-ocaml editors are a light box in both themes, at the code-block font size (in x-ocaml's own monospace face). |

## Verification

1. **Content**: every post, talk, publication, teaching and notes entry appears on its listing with
   the same fields (publications take theirs from `refs.bib`). Per post, the count of math elements in the new HTML (`math inline`/`math
   display`) equals the old count (`\(`, `\[`), except `/posts/2026/10/mb`, which uses `$…$` that
   the old site never rendered and should go from 0 to its full count.
2. **Links**: every local link, image and file in the new `_site/` resolves (link checker over all
   pages).
3. **Clean build**: a fresh `git clone --recurse-submodules` renders with `quarto render`.
4. **Executable code**: knitr and OCaml outputs present; a full render reuses `_freeze/`, and
   editing one page re-runs only that page.
5. **Live code**: per runtime (R, Python, OCaml), a headless browser over http opens the demo page,
   runs each cell and finds the expected output, both on a fresh load and on repeated loads in one
   browser (cached runtime). Math with macros renders on a `live-html` page. Each live page's
   transfer size is recorded; an ordinary post fetches no runtime.
6. **Code look**: for R, C++ and Python, a static block and a live cell show the `code.sty` values
   (headless browser: computed `border-left-color` equals the `code.sty` RGB, background matches,
   `filename=` renders as the title), in both themes; screenshots compared against a pdflatex
   build of the same code in the `code.sty` boxes.

Verifications 4–6 run on a scratch copy of the real site with the test site's code and live samples
added, since no sample page moves. Live OCaml is also checked on the CS 421 notes.

## File scope

In `/home/yasmercy/src/Pages`:

- **Copy from test_pages**: `_quarto.yml`, `styles.scss`, `README.md`, `.gitignore`, `filters/`,
  `_extensions/r-wasm/live/`, the listing pages (`{blog,publications,talks,teaching,notes,news}/index.qmd`),
  `publications/_metadata.yml`, `news/news.ejs`.
- **Create**: `index.qmd`, `404.qmd`, `blog/<slug>.qmd`, `publications/<slug>.qmd`,
  `publications/refs.bib`, `talks/<slug>.qmd`, `teaching/<slug>.qmd`, `notes/<slug>.qmd`,
  `news/news.yml`. Slugs come from the last segment of the current `permalink:` values; the four `mb` posts are
  `blog/mindbenders/<year>-<month>.qmd`, and publications use their BibTeX key.
- **Move**: `files/` and `images/` into `files/site/`, `files/personal/` and
  `files/<section>/<slug>/`: `images/favicon.svg` to `files/site/favicon.svg`,
  `images/SF_profile.jpg` to `files/personal/avatar.jpg`, `files/Ian_Chen_CV.pdf` to
  `files/personal/cv.pdf`. Other images move only if content uses them.
- **Delete**: `_config.yml`, `Gemfile*`, `.bundle/`, `vendor/`, `_includes/`, `_layouts/`, `_sass/`,
  `_data/`, `_pages/`, `_posts/` (incl. stray `_posts/_site/`), `_talks/`, `_publications/`,
  `_teaching/`, `_notes/`, `_drafts/`, `_portfolio/`, `markdown_generator/`, `talkmap*`,
  `talkmap.py`, `.github/workflows/scrape_talks.yml`, `Dockerfile`, `docker-compose.yaml`,
  `.devcontainer/`, `package.json`, `CONTRIBUTING.md`, `.sass-cache/`, the rest of `assets/`,
  `images/` once moved, `scripts/`, `.github/ISSUE_TEMPLATE/`, `files/Ian_Chen_Resume.pdf`.
- **Untouched**: `LICENSE`, `sty/`, `.git*` (except `.gitignore` and `.github/`).
- **Scratch only**: converter, checkers, old `_site/` snapshot, screenshots.

## Steps

Manual git and GitHub steps:
- Before: merge latex-styles `pages` into `main`; move the `sty` submodule to `pages`, with
  `branch = pages` in `.gitmodules`; `git rm -r files/2024-summer-rl`, which also removes its
  submodule from `.gitmodules`.
- After step 6: commit.
- Deploy: switch GitHub Pages source from `master` (legacy Jekyll build) to the `gh-pages` branch;
  run `quarto publish gh-pages`.

Migration (✋ = stop and show output):

1. **Snapshot**: copy the current `_site/` to scratch before Quarto overwrites it (for the math
   counts and side-by-side screenshots).
2. **Infrastructure**: copy the files listed under "Copy from test_pages"; set the real navbar
   (Blog Posts, Notes, Teaching, Talks, Publications, CV) and `site-url`. Render with no content
   besides the listings. ✋
3. **Home page and news**: `index.qmd` with the avatar, email, GitHub and ORCID links and
   the current Bio/Research/SIG text; `news/news.yml` with the current news. Screenshots in both
   themes. ✋
4. **Convert content** with a one-off script:
   - front matter mapped; `tags` → `categories`; venue/location/type → `subtitle`; `excerpt` or
     the first sentence → `description` (checked by hand: no cut formulas);
   - `slidesurl`/`notesurl` → a links line in the body pointing into `files/<section>/<slug>/`;
   - publications: one page per entry of `publications/refs.bib` (five), linking its `paper.pdf` and
     citing the entry with `nocite:`; title and venue come from the entry, and its `keywords` in the
     resume copy give the category (journal → manuscripts, conference → conferences, preprint → preprints);
   - publication fields: `subtitle` is the journal or book title, else the `addendum`, else
     "Preprint"; `description` is the author list; `date` is the entry's month, shown as month and
     year;
   - the CS 421 notes: front matter as the other notes (titles "CS 421: User data types" and
     "CS 421: Type systems"), and `{ocaml}` cells turned into `{.ocaml .live}` blocks. A cell that
     fails on purpose and stops later cells or shows badly becomes a static block with its error
     as text;
   - inline `$$x$$` → `$x$`, inner spaces trimmed (pandoc rejects `$ W $`); display blocks unchanged;
   - files moved into the new layout and every link rewritten;
   - `par_mst` (untracked draft with TODOs) converted with `draft: true`.

   Math-count check, link check, screenshots of each page beside the old one. ✋
5. **404 page**: `404.qmd`.
6. **Remove Jekyll files** (the delete list above).
7. **Checks**: verification 1–6. ✋
8. **After commit**: clean-clone render. After publish: link check against the live site.

## Inventory (as of 2026-11-03)

- Content: 6 posts (incl. untracked `par_mst`, not counting the dropped RL post), 8 talks,
  5 publications (3 have pages today), 2 teaching, 3 notes (not counting the dropped LaTeXML page).
- Front-matter fields in use:
  - posts: `title`, `date`, `permalink`, `tags`.
  - talks: `type`, `venue`, `location`, `date`, `slidesurl`, `citation`.
  - publications: `category`, `venue`, `paperurl`, `bibtexurl`, `citation`, `excerpt`.
  - teaching: `type`, `venue`, `location`, `date`.
  - notes: as teaching, plus `notesurl`.
- Math: posts use kramdown `$$…$$` for inline and display math. MathJax 3 is loaded from
  `_includes/head/custom.html` with default delimiters, so `$…$` is not rendered.
- Raw HTML: `<img>` blocks in `cycle_analysis`, `07-16` and `par_mst`; kept as raw HTML.
- GitHub Pages currently: `build_type: legacy`, source `master` `/`.

## Follow-ups after the migration

- A pass that unifies the school notes, which brings back the MATH 427 notes and can bring in the
  other CS 421 notes with OCaml cells (`08-25`, `09-09`, `09-17`).
- Converting existing posts to executable code. C++ (e.g. `par_mst`): keep the source as a real
  `.cpp` with its Makefile and clangd, show it via knitr's `file=` chunk option and run the build
  from a `bash` chunk, with output frozen.
- Replace hand-copied outputs under `files/posts/<slug>/` (R scripts, PNGs, PDFs) with chunks.
- Turn existing posts' code into live cells where interaction is the point.
- Remote runners for code the browser cannot run well (C++ with threads/`-O3`): a Compiler
  Explorer embed or link beside frozen output.
- `code.sty` look in Typst output.
- Optional Typst/PDF output per page (`format: [html, typst]`) for writeups such as
  `files/posts/07-16-mb/duality.pdf`.
- Moving a course's `sty` pin past the converter refactor: its filter list changes. A document
  listing `typst-adapter.lua` now lists `target-typst.lua`; one listing both now lists
  `typst-adapter.lua`, then `target-typst.lua`.
- Known issues:
  - `code.sty`: `cppcode` without `[]` fails when the body starts with `#`.
  - Code output inside list items is not indented (seen in `hw7`).
  - Wide inference rules scroll horizontally in the text column.
  - `\textcolor{red}` has poor contrast in dark mode.
  - Possibly revisit: dark-mode code-border colours, and x-ocaml's light-only styling
    (an upstream request).

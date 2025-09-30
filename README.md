# CVs in this repo

This repository contains two LaTeX CVs:

- `autocv/` — autoCV template (`cv.tex`).
- `russell_cv/` — russell class (`resume.tex`).

Only `README.md` and `index.html` live at the repo root. To publish/use one CV at the site root, move the chosen CV up to `./` before building or deploying (see “Choosing which CV to use”).

## Compile instructions

### autoCV (`autocv/`)
- Prereqs: LaTeX with `latexmk`, `biblatex`/`biber`.
- Build:
```bash
cd autocv
make
# outputs: cv.pdf
```
- Clean:
```bash
cd autocv
make clean       # intermediates
make distclean   # also removes cv.pdf
```

### russell CV (`russell_cv/`)
- Prereqs: XeLaTeX and packages/fonts from `russell.cls` (fontspec, unicode-math, fontawesome5, roboto, sourcesanspro, tcolorbox, tikz/pgf, biblatex + biber).
- Build:
```bash
cd russell_cv
xelatex -interaction=nonstopmode -halt-on-error resume.tex
biber resume
xelatex -interaction=nonstopmode -halt-on-error resume.tex
xelatex -interaction=nonstopmode -halt-on-error resume.tex
# outputs: resume.pdf
```

## Choosing which CV to use

The site expects the active CV at the repository root. To switch:

- Use autoCV at root:
  - Move `autocv/cv.tex` and related project files (e.g., `citations.bib`, `Makefile`) to `./`.
  - Or keep building inside `autocv/` and copy `autocv/cv.pdf` to `./cv.pdf` for publishing.

- Use russell CV at root:
  - Move `russell_cv/resume.tex` and its `cv/` directory (and `fonts/` if needed) to `./`.
  - Or keep building inside `russell_cv/` and copy `russell_cv/resume.pdf` to `./resume.pdf` (or `./cv.pdf`) for publishing.

Tip: instead of moving, you can symlink the chosen CV into `./` if your hosting workflow supports it.


# CV

LaTeX source for my CV (russell class), in `my_cv/`.

## Build

Prereqs: XeLaTeX, Biber, and the packages/fonts used by `my_cv/russell.cls`.

```bash
./my_cv/build.sh          # builds the PDF and the Markdown version
./my_cv/build.sh clean    # removes auxiliary files
```

The build writes the PDF to `cv.pdf` at the repo root. That is the only PDF in the repo, and GitHub Pages serves it at
[dundalia.github.io/CV/cv.pdf](https://dundalia.github.io/CV/cv.pdf) (`index.html` redirects there).

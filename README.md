# rocq-solid

Talk and companion Rocq development. The slides use
[Touying](https://typst-doc-cn.github.io/typst-touying-doc/)'s `metropolis`
theme with the coral accent of
[encore-slides](https://github.com/vbergeron/encore-slides) and
[data-processing-at-scale](https://github.com/vbergeron/data-processing-at-scale);
published to GitHub Pages.

**Site:** https://vbergeron.github.io/rocq-solid/

## Layout

```
theories/            Rocq sources: the `Solid` theory, built by dune
extraction/          Orders.v extracted to OCaml and compiled, by dune
dune-project         dune + Rocq setup (rocq-solid.opam is generated from it)
template/lib.typ     slide template: theme, `rocq-file`, `hero`, QR slides
template/syntaxes/   Rocq highlighting grammar (Typst bundles none)
template/fonts/      Fira Code (OFL) for code, with its ligatures
decks/               the talk(s), one .typ file each
site/index.html      the GitHub Pages site listing every deck
mise.toml            tools (Typst, opam) and tasks
```

## Setup

[mise](https://mise.jdx.dev) installs Typst and opam; opam then builds a
local switch in `_opam/` with OCaml, dune and Rocq 9.1 (opam needs the usual
system packages: a C toolchain, `make`, `patch`, `unzip`, `bubblewrap`).

```sh
mise install        # typst + opam
mise run setup      # local opam switch in _opam/ (compiles Rocq, takes a while)
```

## Tasks

```sh
mise run build                  # dune build: check every proof
mise run clean                  # dune clean
eval "$(mise run shell)"        # put the switch's rocq/dune on PATH (editors, rocq top)

mise run slides                 # compile decks/rocq-solid.typ to rocq-solid.pdf
mise run slides decks/other.typ # compile another deck
mise run watch                  # live recompile while editing
mise run slides-all             # every deck into site/decks/
mise tasks                      # list all tasks
```

Or plain Typst; decks import the template root-absolutely, so `--root .` is
required, and code is set in the vendored Fira Code, so is `--font-path
template/fonts`: `typst compile --root . --font-path template/fonts
decks/rocq-solid.typ`.

## Writing slides

Each `= Section` opens a section slide and each `== Title` a new slide.
`rocq-file("/theories/Intro.v", lines: (20, 25))` shows a range of a checked
source file, so the code on screen is the code `mise run build` checks;
fenced ```` ```rocq ```` blocks are highlighted too. `#todo[..]` marks content
still to write, in grey italics.

`solid-theme` opens with a title slide and, if `slug` is set, a "Follow
along" slide with two QR codes side by side: the deck's PDF
(`https://vbergeron.github.io/rocq-solid/decks/<slug>.pdf`) and the site. It
closes with a "Go further" slide holding a QR code for each entry in `links`.
A new deck also needs a matching entry in the Slides list of
`site/index.html`, linking to `decks/<slug>.pdf`.

Avoid an em dash directly before a raw span (`` — `foo` ``): Touying reads it
as a pause marker and splits the slide.

## CI

`.github/workflows/build.yml` checks the proofs in the `rocq/rocq-prover:9.1`
image and compiles the decks, uploading the PDFs as a build artifact. On every
push to `main`, once both pass, it compiles every deck into `site/decks/` and
deploys `site/` to GitHub Pages (the repository's Pages source must be set to
"GitHub Actions").

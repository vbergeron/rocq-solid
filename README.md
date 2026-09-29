# rocq-solid

Talk and companion Rocq development. The slides use
[Touying](https://typst-doc-cn.github.io/typst-touying-doc/)'s `metropolis`
theme with the coral accent of
[encore-slides](https://github.com/vbergeron/encore-slides) and
[data-processing-at-scale](https://github.com/vbergeron/data-processing-at-scale).

## Layout

```
theories/            Rocq sources: the `Solid` theory, built by dune
dune-project         dune + Rocq setup (rocq-solid.opam is generated from it)
template/lib.typ     slide template: theme, `rocq-file`, `hero`, QR slides
template/syntaxes/   Rocq highlighting grammar (Typst bundles none)
decks/               the talk(s), one .typ file each
scripts/rocq         runs a command with Rocq on PATH (Docker or opam, see below)
mise.toml            tools (Typst, opam) and tasks
```

## Setup

[mise](https://mise.jdx.dev) installs Typst (`mise install`). Rocq runs in one
of two backends, picked by `ROCQ_BACKEND`:

- `docker` (default): the `rocq/rocq-prover:9.1` image, the one CI uses.
  Nothing to build; the repository is mounted in the container, which runs as
  your user so `_build/` stays yours.
- `opam`: a local opam switch in `_opam/` with OCaml, dune and Rocq 9.1,
  built from source (slow the first time; opam needs a C toolchain, `make`,
  `patch`, `unzip` and `bubblewrap`). Useful for editor integration.

```sh
mise install                         # typst (+ opam)
mise run setup                       # docker pull the image
ROCQ_BACKEND=opam mise run setup     # or: build the local switch
```

To use opam permanently, put `ROCQ_BACKEND = "opam"` under `[env]` in a
git-ignored `mise.local.toml`, or export it in your shell.

## Tasks

```sh
mise run build                  # dune build: check every proof
mise run clean                  # dune clean
mise run rocq rocq top          # any command with Rocq on PATH (here a toplevel)
mise run rocq bash              # a shell in the Rocq environment

mise run slides                 # compile decks/rocq-solid.typ to rocq-solid.pdf
mise run slides decks/other.typ # compile another deck
mise run watch                  # live recompile while editing
mise run slides-all             # every deck into site/decks/
mise tasks                      # list all tasks
```

`scripts/rocq` works without mise too: `scripts/rocq dune build`.

Or plain Typst; decks import the template root-absolutely, so `--root .` is
required: `typst compile --root . decks/rocq-solid.typ`.

## Writing slides

Each `= Section` opens a section slide and each `== Title` a new slide.
`rocq-file("/theories/Intro.v", lines: (20, 25))` shows a range of a checked
source file, so the code on screen is the code `mise run build` checks;
fenced ```` ```rocq ```` blocks are highlighted too.

Setting `slug` in `solid-theme.with(..)` adds a "Follow along" slide with QR
codes to `https://vbergeron.github.io/rocq-solid/decks/<slug>.pdf`, which
assumes the decks get published to GitHub Pages; entries in `links` become a
closing "Go further" QR slide.

Avoid an em dash directly before a raw span (`` — `foo` ``): Touying reads it
as a pause marker and splits the slide.

## CI

`.github/workflows/build.yml` checks the proofs with `mise run build` (the
Docker backend) and compiles the decks, uploading the PDFs as a build
artifact.

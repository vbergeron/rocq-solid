// rocq-solid — same theme as vbergeron/encore-slides and
// vbergeron/data-processing-at-scale: touying's metropolis theme, coral
// accent, tiaoma QR codes.

#import "@preview/touying:0.6.3": *
#import themes.metropolis: *
#import "@preview/tiaoma:0.3.0"

#let coral = rgb("#B5303B")
#let coral-light = rgb("#d4777e")

#let base-url = "https://vbergeron.github.io/rocq-solid/"

#let hero(body) = align(center + horizon, text(size: 28pt, body))

// A slide whose header carries `title` (e.g. the section's name) and whose
// body opens with `message`, large: the one thing the slide must say.
#let message-slide(title: none, message: none, body) = slide(
  title: title,
  align: top,
)[
  #if message != none {
    v(0.3em)
    text(size: 30pt, weight: "bold", fill: rgb("#23373b"), message)
  }
  #v(1fr)
  #body
  #v(1fr)
]

// Placeholder for slide content still to write.
#let todo(body) = text(fill: luma(140), style: "italic")[TODO: #body]

// A Rocq source file from the repository, shown verbatim: the code on the
// slide is the code `mise run build` checks. `path` is root-absolute
// (e.g. "/theories/Intro.v"); `lines` optionally keeps a 1-based,
// inclusive range, e.g. `lines: (5, 10)`.
#let rocq-file(path, lines: none, size: 1em) = {
  let src = read(path)
  if lines != none {
    src = src.split("\n").slice(lines.at(0) - 1, lines.at(1)).join("\n")
  }
  text(size: size, raw(src, lang: "rocq", block: true))
}

// A toolchain, left to right: stages `(name, note)` alternating with the
// label of the step between them. The first stage, where the proofs live,
// is tinted.
//   #pipeline(([Rocq], [reducer + proofs]), [extraction], ([OCaml], [hook]))
#let pipeline(..items) = {
  let ink = rgb("#23373b")
  let stage(name, note, fill: luma(240)) = box(
    width: 4.4cm,
    fill: fill,
    radius: 6pt,
    inset: (y: 0.6em),
    align(center)[
      #text(weight: "bold", fill: ink, name) \
      #text(size: 0.65em, fill: luma(100), note)
    ],
  )
  let step(label) = align(center)[
    #text(size: 0.55em, style: "italic", fill: luma(120), label) \
    #text(size: 1.1em, fill: luma(150))[$arrow.long$]
  ]
  let items = items.pos()
  align(center, grid(
    columns: items.len(),
    column-gutter: 0.3em,
    align: horizon,
    ..items.enumerate().map(((i, it)) => if calc.odd(i) { step(it) } else {
      stage(..it, fill: if i == 0 { coral.lighten(88%) } else { luma(240) })
    })
  ))
}

#let qr-card(url, label: none, width: 4cm) = align(center)[
  #tiaoma.qrcode(url, width: width)
  #v(0.4em)
  #if label != none [
    #text(size: 12pt, weight: "bold")[#label]
    #v(0.2em)
  ]
  #text(size: 10pt, fill: luma(120))[#link(url)[#url]]
]

#let solid-theme(
  title: [],
  subtitle: [],
  author: [Valentin Bergeron],
  institution: [],
  date: datetime.today(),
  slug: "",
  links: (),
  body,
) = {
  // Typst bundles no Rocq grammar; this one answers to `coq`, `rocq` and `v`.
  set raw(syntaxes: "syntaxes/rocq.sublime-syntax")
  // Fira Code, vendored in template/fonts/ (compile with --font-path
  // template/fonts): its ligatures turn -> into an arrow, /\ into a wedge.
  show raw: set text(font: "Fira Code")
  show: metropolis-theme.with(
    aspect-ratio: "16-9",
    footer: self => self.info.institution,
    config-common(
      datetime-format: "[weekday], [month repr:long] [day padding:none], [year]",
    ),
    config-colors(
      primary: coral,
      primary-light: coral-light,
    ),
    config-info(
      title: title,
      subtitle: subtitle,
      author: author,
      date: date,
      institution: institution,
    ),
  )
  title-slide()

  // "Follow along" QR codes: the deck's PDF and the site. Needs the deck
  // published at base-url + "decks/" + slug + ".pdf". Shown after the title
  // and again as the closing slide.
  let follow-along = if slug != "" {
    slide[
      #align(center + horizon)[
        #text(size: 24pt, weight: "bold")[Follow along]
        #v(1em)
        #grid(
          columns: (1fr, 1fr),
          column-gutter: 2cm,
          align: center,
          qr-card(base-url + "decks/" + slug + ".pdf", label: "Slides", width: 5cm),
          qr-card(base-url, label: "Site", width: 5cm),
        )
      ]
    ]
  }
  follow-along

  body

  follow-along

  if links.len() > 0 {
    slide[
      #align(center + horizon)[
        #text(size: 24pt, weight: "bold")[Go further]
        #v(1em)
        #grid(
          columns: links.len() * (1fr,),
          column-gutter: 2cm,
          align: center,
          ..links.map(l => qr-card(l.url, label: l.label))
        )
      ]
    ]
  }
}

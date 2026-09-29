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
  show: metropolis-theme.with(
    aspect-ratio: "16-9",
    footer: self => self.info.institution,
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
  // published at base-url + "decks/" + slug + ".pdf".
  if slug != "" {
    slide(title: [Follow along])[
      #align(center + horizon)[
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

  body

  if links.len() > 0 {
    slide(title: [Go further])[
      #align(center + horizon)[
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

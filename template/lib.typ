// rocq-solid — same theme as vbergeron/encore-slides and
// vbergeron/data-processing-at-scale: touying's metropolis theme, coral
// accent, tiaoma QR codes.

#import "@preview/touying:0.6.3": *
#import themes.metropolis: *
#import "@preview/tiaoma:0.3.0"

#let coral = rgb("#B5303B")
#let coral-light = rgb("#d4777e")

#let base-url = "https://vbergeron.github.io/rocq-solid/"

// Type scale: every size on a slide comes from here, so that two slides
// never set the same kind of text differently. Body text is metropolis'
// 20pt; `size-dense` is for slides that share the space with code or a
// figure, `size-note` for captions, sources and links.
#let size-hero = 28pt
#let size-dense = 17pt
#let size-note = 13pt
// Code blocks: `code-size` everywhere it fits, `code-small` for code set
// side by side or long listings. Never anything else.
#let code-size = 16pt
#let code-small = 13pt

#let ink = rgb("#23373b")

#let hero(body) = align(center + horizon, text(size: size-hero, body))

// Captions, sources and links: small and grey.
#let note(body) = text(size: size-note, fill: luma(110), body)

// The one-sentence takeaway of a dense slide, in a grey box.
#let callout(body) = block(
  fill: luma(238),
  inset: (x: 0.8em, y: 0.6em),
  radius: 4pt,
  body,
)

// Code set at `code-small`, e.g. `#small-code[```ocaml ...```]`.
#let small-code(body) = {
  show raw.where(block: true): set text(size: code-small)
  body
}

// A moment of Jack's story: when, grey and small, then what happened.
#let moment(when, body) = align(horizon)[
  #text(size: 18pt, fill: luma(110), weight: "bold", when)
  #v(0.2em)
  #text(size: 26pt, body)
]

// A slide whose header carries `title` (e.g. the section's name) and whose
// body opens with `message`, large: the one thing the slide must say.
#let message-slide(title: none, message: none, body) = slide(
  title: title,
  align: top,
)[
  #if message != none {
    v(0.3em)
    text(size: 30pt, weight: "bold", fill: ink, message)
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
// inclusive range, e.g. `lines: (5, 10)`, or several, e.g.
// `lines: ((7, 15), (23, 23))`, shown in one block with a blank line
// between them.
#let rocq-file(path, lines: none, size: code-size) = {
  let src = read(path)
  if lines != none {
    let all = src.split("\n")
    let ranges = if type(lines.at(0)) == array { lines } else { (lines,) }
    src = ranges.map(r => all.slice(r.at(0) - 1, r.at(1)).join("\n")).join("\n\n")
  }
  show raw.where(block: true): set text(size: size)
  raw(src, lang: "rocq", block: true)
}

#let qr-card(url, label: none, width: 4cm) = align(center)[
  #tiaoma.qrcode(url, width: width)
  #v(0.4em)
  #if label != none [
    #text(size: 16pt, weight: "bold")[#label]
    #v(0.2em)
  ]
  #note(link(url)[#url])
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
  // Code blocks: one size, tight lines, on a light grey card.
  show raw.where(block: true): set text(size: code-size)
  show raw.where(block: true): set par(leading: 0.5em)
  show raw.where(block: true): it => block(
    width: 100%,
    fill: luma(242),
    inset: (x: 0.7em, y: 0.6em),
    radius: 4pt,
    it,
  )
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
  // published at base-url + "decks/" + slug + ".pdf".
  if slug != "" {
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

  body

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

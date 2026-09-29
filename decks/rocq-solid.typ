#import "/template/lib.typ": *

#show: solid-theme.with(
  title: [Rocq Solid],
  subtitle: [Subtitle of the talk],
  institution: [Conference],
  // date: datetime(year: 2026, month: 10, day: 1),
  // slug: "rocq-solid",  // adds a "Follow along" QR slide, see template/lib.typ
  links: (
    (url: "https://github.com/vbergeron/rocq-solid", label: "Sources"),
    (url: "https://rocq-prover.org", label: "Rocq"),
  ),
)

= Introduction

== Outline

- First part
- Second part
- *Emphasis* renders in the coral accent

== A statement

#hero[One idea per slide, *stated big*.]

= Rocq

== Code, inline

```rocq
Fixpoint rev {A : Type} (l : list A) : list A :=
  match l with
  | [] => []
  | x :: xs => rev xs ++ [x]
  end.
```

== Code, from the checked sources

#rocq-file("/theories/Intro.v", lines: (20, 25))

== Two columns

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1cm,
  [
    - Left column
    - Bullet points
  ],
  rocq-file("/theories/Intro.v", lines: (12, 18), size: 0.8em),
)

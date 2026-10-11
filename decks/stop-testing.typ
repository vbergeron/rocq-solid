#import "/template/lib.typ": *

// Five-minute lightning talk for ScalaDays 2026.
// No slug: the theme then skips its QR slides.

#show: solid-theme.with(
  title: [Stop testing, start proving],
  institution: [ScalaDays 2026],
  date: none,
)

== Hey Claude !

#hero("Can you implement partial refunds ?")

== Partial refunds

```scala
case class Order(id: OrderId, paid: Money, refund: Option[Refund])

def canRefund(o: Order, amount: Money): Boolean =
  o.refund.isEmpty || o.refund.head.amount + amount <= o.paid
```

== Look mom, `Iterable`

```scala
case class Order(id: OrderId, paid: Money, refunds: List[Refund])

def canRefund(o: Order, amount: Money): Boolean =
  o.refunds.isEmpty || o.refunds.head.amount + amount <= o.paid
```

== Vacuusly True Driven Development

```scala
test("a refund never exceeds what was paid") {
  val order   = Fixtures.paidOrder(amount = 100)
  val refunds = db.refunds.findByOrder(order.id)
  refunds.foreach { r =>
    assert(r.amount <= order.paid)
  }
}
```

== Meanwhile, in `Fixtures.scala`

```scala
object Fixtures:
  def paidOrder(amount: Money): Order =
    db.orders.insert(Order(OrderId.random(), paid = amount, refunds = Nil))
```

== Everything was green

#grid(
  columns: (2fr, 1fr),
  column-gutter: 1cm,
  align: horizon,
  [
    Every test was green
    #v(1em)
    Every pull request was reviewed and approved
    #v(1em)
    The code did exactly what it said
    #v(1em)
    #text(size: size-hero)[Nobody wrote down *what must be true*.]
  ],
  image("images/klod.jpg", width: 100%),
)

==

#hero("It is all about proofs and trust.")


== Yes obviously some guys have thought about it

#{
  // One column per school: portrait, name, motto, members.
  let school(img, name, motto, members) = align(center, stack(
    spacing: 0.5em,
    box(clip: true, radius: 6pt, image(img, height: 6.5cm)),
    text(size: 24pt, weight: "bold", fill: coral, name),
    text(size: size-dense, motto),
    note(members),
  ))
  align(center + horizon, grid(
    columns: (1fr, auto, 1fr),
    column-gutter: 1cm,
    align: horizon,
    school("images/hume.jpg", [Empiricists],
      [Knowledge comes from *experience*], [Locke, Berkeley, Hume]),
    text(size: 32pt, weight: "bold", fill: luma(160))[VS],
    school("images/descartes.webp", [Rationalists],
      [Knowledge comes from *reason*], [Descartes, Spinoza, Leibniz]),
  ))
}

== Curry–Howard: proofs are programs

*Theorem (Curry 1934–1958, Howard 1969).*

Proofs in intuitionistic logic are exactly the programs of the typed $lambda$-calculus:
a proposition is provable if and only if the corresponding type has a program.

#v(0.6em)
#callout[*Checking a proof = checking a program's type.*]


== Theorem provers: Rocq

#grid(
  columns: (1fr, 6cm),
  column-gutter: 1cm,
  align: horizon,
  [
    A type system powerful enough to express *arbitrary theorems*\
    Inria in 1984.\
    *Coq* -> *Rocq* in 2025

    #v(0.6em)
  ],
  image("/template/images/rocq-logo.svg", width: 100%),
)


== A theorem and its proof

#rocq-file("/theories/Orders.v", lines: (51, 52))

== A theorem and its proof

#rocq-file("/theories/Orders.v", lines: (51, 59))

== Vericoding

#align(center + horizon, {
  import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
  let actor(pos, name, body, ..args) = node(
    pos,
    box(width: 6.2cm, align(center)[
      #block(height: 1cm, align(horizon, body))
      #text(size: 1.05em, weight: "bold", fill: ink, name)
    ]),
    fill: luma(240),
    corner-radius: 6pt,
    inset: 12pt,
    ..args,
  )
  set text(size: 18pt)
  diagram(
    spacing: (3.2cm, 2.2cm),
    edge-stroke: 1.5pt + ink,
    edge-corner-radius: 6pt,
    mark-scale: 80%,
    actor((0, 0), [You], text(size: 1.6em)[👤]),
    actor((1, 0), [AI agent], text(size: 1.6em)[🤖]),
    actor((2, 0), [Prover], text(size: 1.6em)[⚖️], stroke: 1.5pt + coral),
    edge((0, 0), (1, 0), "-|>", text(size: 0.7em)[specification], label-side: left),
    edge((1, 0), (2, 0), "-|>", text(size: 0.7em)[proof attempts],
      label-side: left, bend: 25deg),
    edge((2, 0), (1, 0), "-|>", text(size: 0.7em)[goals, errors],
      label-side: left, bend: 25deg),
    node((1.5, 0), text(size: 0.6em, weight: "bold", fill: white)[MCP],
      fill: coral, corner-radius: 3pt, inset: 4pt),
    edge((2, 0), (2, 0.9), (0, 0.9), (0, 0), "-|>",
      text(size: 0.7em, fill: coral)[*✓ proved*],
      stroke: 1.5pt + coral, label-side: left),
  )
})


== Extraction: from proof to production

#align(center + horizon, {
  import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
  let logo(file, h: 0.6cm) = image("images/logos/" + file, height: h)
  // A target language: a wordmark logo stands alone, a symbol logo gets
  // the name next to it; how Rocq gets there goes in small print.
  let lang(pos, name, mark: none, wordmark: none, how: none, ..args) = node(
    pos,
    box(width: 4.4cm, height: 1.3cm, align(center + horizon, stack(
      spacing: 0.25em,
      if wordmark != none { wordmark } else {
        stack(dir: ltr, spacing: 0.3em,
          ..if mark != none { (align(horizon, mark),) },
          align(horizon, text(weight: "bold", fill: ink, name)))
      },
      ..if how != none { (text(size: 0.65em, fill: luma(110), how),) },
    ))),
    fill: luma(240), corner-radius: 6pt, inset: 8pt, ..args,
  )
  let dashed = (paint: coral, thickness: 1.5pt, dash: "dashed")
  set text(size: 18pt)
  diagram(
    spacing: (1.6cm, 0.35cm),
    edge-stroke: 1.5pt + ink,
    mark-scale: 80%,
    lang((0, 2), [Rocq], stroke: 1.5pt + coral,
      wordmark: image("/template/images/rocq-logo.svg", height: 0.7cm)),
    lang((1, 0), [OCaml], wordmark: logo("ocaml.svg", h: 0.75cm)),
    lang((1, 1), [Scheme], mark: logo("scheme.svg")),
    lang((1, 2), [Haskell], mark: logo("haskell.svg")),
    lang((1, 3), [C], mark: logo("c.svg"), how: [via CertiRocq]),
    lang((1, 4), [Scala], wordmark: logo("scala.svg", h: 0.85cm),
      how: [*new:* via a plugin], stroke: dashed),
    lang((2, 0), [JavaScript], mark: logo("javascript.svg"), how: [via Melange]),
    lang((2, 1), [Encore VM], how: [microcontrollers]),
    // A tree: out of Rocq to a vertical bus, then right to each target.
    // Scala first, so the solid trunk is drawn over its dashed part.
    edge((0, 2), (0.5, 2), (0.5, 4), (1, 4), "-|>", stroke: dashed),
    ..range(4).map(r => if r == 2 { edge((0, 2), (1, 2), "-|>") } else {
      edge((0, 2), (0.5, 2), (0.5, r), (1, r), "-|>")
    }),
    edge((1, 0), (2, 0), "-|>"),
    edge((1, 1), (2, 1), "-|>"),
  )
})

== Rocq-solid

#align(center + horizon)[
  #text(size: size-hero)[Be the one who writes down *what must be true*.]
  #v(1.5em)
  #qr-card(base-url, width: 4.5cm)
]

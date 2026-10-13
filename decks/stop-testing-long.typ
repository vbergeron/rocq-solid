#import "/template/lib.typ": *

// Long version of "Stop testing, start proving" (decks/stop-testing.typ):
// the same Scala story, followed by slides merged in from
// decks/rocq-solid.typ. The slug matches the PDF that `mise run slides-all`
// publishes to GitHub Pages, for the QR slides at both ends.

#show: solid-theme.with(
  title: [Stop testing, start proving],
  institution: [Typelevel Traverses Berlin],
  date: none,
  slug: "stop-testing-long",
)

// A small coral label above each listing.
#let tag(body) = text(size: size-dense, weight: "bold", fill: coral, body)

= Everything was green

== The context

#grid(
  columns: (2fr, 1fr),
  column-gutter: 1cm,
  align: horizon,
  [
    - A Scala backend for a small e-commerce startup
    - A roadmap that doubles every quarter
    - Claude writes the code. Claude writes the tests. Life is good.
  ],
  image("images/klod.jpg", width: 100%),
)

== Hey Claude !

#hero[
  Hey Claude, can you implement partial refunds please ? \
  Make no mistakes !!

  #pause
  #v(1em)
  Result: #text(fill: coral)[*180k€ loss in one weekend*]
]

== Look mom, `Iterable`

// Same place on screen: on the click, the code after the refactor.
#alternatives(
  [
    #tag[Before]
    ```scala
    case class Order(id: OrderId, paid: Money, refund: Option[Refund])

    def canRefund(o: Order, amount: Money): Boolean =
      o.refund.isEmpty || o.refund.head.amount + amount <= o.paid
    ```
  ],
  [
    #tag[After]
    ```scala
    case class Order(id: OrderId, paid: Money, refunds: List[Refund])

    def canRefund(o: Order, amount: Money): Boolean =
      o.refunds.isEmpty || o.refunds.head.amount + amount <= o.paid
    ```
  ],
)

== Vacuously True Driven Development

// Same place on screen: on the click, the fixture the test relies on.
// Both boxes share a height so the shorter listing stays at the top.
#alternatives(
  block(height: 6.5cm)[
    #set align(top)
    #tag[The test]
    ```scala
    test("a refund never exceeds what was paid") {
      val order   = Fixtures.paidOrder(amount = 100)
      val refunds = db.refunds.findByOrder(order.id)
      refunds.foreach { r =>
        assert(r.amount <= order.paid)
      }
    }
    ```
  ],
  block(height: 6.5cm)[
    #set align(top)
    #tag[Meanwhile, in `Fixtures.scala`]
    ```scala
    object Fixtures:
      def paidOrder(amount: Money): Order =
        db.orders.insert(Order(OrderId.random(), paid = amount, refunds = Nil))
    ```
  ],
)

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
  image("images/tehc.png", width: 100%),
)

= It is all about proofs and trust

==

#hero("It is all about proofs and trust.")

== Descartes as a shadow FP maximalist ?

// One column per school: portrait, name, motto, members.
#let school(img, name, motto, members) = align(center, stack(
  spacing: 0.5em,
  box(clip: true, radius: 6pt, image(img, height: 6.5cm)),
  text(size: 24pt, weight: "bold", fill: coral, name),
  text(size: size-dense, motto),
  note(members),
))
#let versus(left, right) = align(center + horizon, grid(
  columns: (1fr, auto, 1fr),
  column-gutter: 1cm,
  align: horizon,
  left,
  text(size: 32pt, weight: "bold", fill: luma(160))[VS],
  right,
))

// Same layout twice: on the click, the schools get their modern names.
#alternatives(
  versus(
    school("images/hume.jpg", [Empiricists],
      [Knowledge comes from *experience*], [Locke, Berkeley, Hume]),
    school("images/descartes.webp", [Rationalists],
      [Knowledge comes from *reason*], [Descartes, Spinoza, Leibniz]),
  ),
  versus(
    school("images/hume.jpg", [Testers],
      [Trust the CI bro], [Locke, Berkeley, Hume]),
    school("images/descartes.webp", [Typers],
      [If it compiles it works], [Descartes, Spinoza, Leibniz]),
  ),
)


== Collatz: evidence without proof

#set text(size: size-dense)

#grid(
  columns: (1.12fr, 1fr),
  column-gutter: 1cm,
  align: horizon,
  [
    *The rule:* take any $n$. If even, $n -> n/2$; if odd, $n -> 3n+1$. Repeat.

    *Conjecture (Collatz, 1937):* you always end up at 1.

    $6 -> 3 -> 10 -> 5 -> 16 -> 8 -> 4 -> 2 -> 1$

    - Checked for every $n$ up to $2^71 approx 2.36 times 10^21$ (Barina, 2025)
    - Still no proof

    #callout[
      Billions of billions of cases ≠ certainty: the next number could be the exception.
    ]
  ],
  image("images/collatz.png", width: 100%, height: 85%, fit: "contain"),
)

== Reason alone: truths no experiment can reach

#set text(size: size-dense)

#grid(
  columns: (2fr, 1fr),
  rows: (1fr, 1fr),
  column-gutter: 1cm,
  row-gutter: 0.6cm,
  align: horizon,
  [
    *There are infinitely many primes* (Euclid, c. 300 BCE) \
    Suppose the list is finite: $p_1, ..., p_n$. Then $N = p_1 p_2 dots.c p_n + 1$ leaves remainder 1 when divided by each $p_i$, so its prime factors are missing from the list. Contradiction.
  ],
  image("images/ulam.jpg", height: 100%),
  [
    *$sqrt(2)$ is irrational* (Pythagoreans, 5th c. BCE) \
    Suppose $sqrt(2) = p/q$ in lowest terms. Then $p^2 = 2q^2$, so $p$ is even: $p = 2k$. Then $q^2 = 2k^2$, so $q$ is even too. Contradiction.
  ],
  image("images/sqrt2.webp", height: 100%),
)

= Theorem provers

== Curry–Howard: proofs are programs

*Theorem (Curry 1934–1958, Howard 1969).*

Proofs in intuitionistic logic are exactly the programs of the typed $lambda$-calculus:
a proposition is provable if and only if the corresponding type has a program.

#v(0.6em)
#callout[*Checking a proof = checking a program's type.*]

== Theorem provers

#hero[
  A theorem prover *is* a type checker \
  for a language whose type system is powerful enough \
  to express *arbitrary statements about its terms*.
]

== The Four Colour Theorem: a proof no human can read

#set text(size: size-dense)

#grid(
  columns: (1.6fr, 1fr),
  column-gutter: 1cm,
  align: horizon,
  [
    _Any map can be coloured with 4 colours so that neighbouring regions differ._

    #table(
      columns: (auto, 1fr),
      inset: (x: 0pt, y: 5pt),
      column-gutter: 0.6em,
      align: left + horizon,
      stroke: none,
      [*1879*], [Kempe publishes a "proof", accepted for 11 years],
      [*1890*], [Heawood finds the flaw: back to square one],
      [*1976*], [Appel & Haken: a computer checks ~1,900 cases in over 1,000 hours],
      [*1996*], [Robertson, Sanders, Seymour & Thomas: a simpler proof, still computer-assisted],
      [*2005*], [Gonthier verifies the full proof in the Coq proof assistant],
    )

    #callout[
      If no human can check it, is it still a proof? Do we _know_ the theorem, or do we _trust_ the machine?
    ]
  ],
  image("images/4color.png", width: 100%, height: 100%, fit: "contain"),
)
== Theorem Provers : Rocq

#grid(
  columns: (1.4fr, 1fr),
  column-gutter: 1cm,
  align: horizon,
  table(
    columns: (auto, 1fr),
    inset: (x: 0pt, y: 5pt),
    column-gutter: 0.6em,
    align: left + horizon,
    stroke: none,
    [*1984*], [Coquand and Huet start it at Inria],
    [*1989*], [First release, named *Coq*],
    [*2005*], [*The four colour theorem*, checked],
    [*2006*], [CompCert, a C compiler proved correct],
    [*2013*], [ACM Software System Award],
    [*2025*], [Renamed *Rocq*, after Rocquencourt],
  ),
  image("/template/images/rocq-logo.svg", width: 100%),
)

== Theorem Provers

#align(center + horizon, image("/template/images/lean-logo.svg", width: 35%))

== Theorem Provers

#{
    let card(name, hook, body) = box(
      width: 100%,
      height: 3.9cm,
      fill: luma(240),
      radius: 6pt,
      inset: 0.8em,
      [
        #text(size: 22pt, weight: "bold", fill: coral, name) \
        #text(size: 16pt, weight: "bold", hook) \
        #v(-0.2em)
        #text(size: 14pt, fill: luma(80), body)
      ],
    )
    grid(
      columns: (1fr,) * 3,
      column-gutter: 0.6cm,
      row-gutter: 0.6cm,
      card[Isabelle][An OS kernel, proved][seL4 flew a military helicopter that
        red teams could not break into],
      card[F\*][You used it today][HACL\*, the proved crypto inside Firefox,
        Linux and Python],
      card[Dafny][At the heart of AWS][The engine that evaluates IAM policies,
        rewritten and proved],
      card[TLA+][Bugs caught before the code][Amazon found subtle design bugs in
        S3 and DynamoDB],
      card[ACL2][The Pentium, never again][AMD proved its floating point
        division in 1996],
      card[Agda][Proofs are programs][The playground where type theorists try
        their ideas first],
    )
}

= Vericoding

== Vericoding

#hero[Writing a proof is hard.

Writing *what you want to prove* is much easier.]

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

== Example: the code

#grid(
  columns: (1.05fr, 1fr),
  column-gutter: 0.6cm,
  align: horizon,
  rocq-file("/theories/Orders.v", lines: (7, 15), size: code-small),
  small-code({
    // Signatures only, read from the checked file: bodies elided, the
    // arguments on their own line so that both columns fit.
    let src = read("/theories/Orders.v").split("\n")
    let sig(n) = {
      let l = src.at(n - 1).trim()
      let i = l.position(" (")
      l.slice(0, i) + "\n " + l.slice(i) + " ..."
    }
    raw(lang: "rocq", block: true, (
      "(* Was this event already handled? *)", sig(20), "",
      "(* Apply one event to an order. *)", sig(23), "",
      "(* The order, rebuilt from its events. *)", sig(38),
    ).join("\n"))
  }),
)

== Example: the specification

#rocq-file("/theories/Orders.v", lines: (51, 52))

#v(0.6em)
- Written by *you*: an order never refunds more than it was paid
- True for *every* sequence of events: not just the cases you thought of testing
- Two lines to review, readable *without the proof*

== Example: the proof

#rocq-file("/theories/Orders.v", lines: ((42, 49), (51, 59)), size: code-small)

#v(0.3em)
#set text(size: size-dense)
- Written by *the agent*: first a lemma about *one* event, then induction over *all* of them
- `Qed.`: Rocq accepted every step. A wrong proof *does not compile*
- You do not have to read it, only the statement


// Part 5 is copied verbatim from the two decks and will be reworked.
= Shipping proved code
==
#align(center + horizon, image("images/sacrifice.jpg", height: 85%))

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
== What it changes in your architecture

#align(center)[A proved decisional *core*, a thin interpreting *shell*]

#align(center + horizon, {
  import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
  // Three layers, one inside the other: the world, the shell, the core.
  // Each step names what crosses it: clicks and messages come in, the
  // shell turns them into events, the core turns events into decisions,
  // the shell turns decisions into effects on the world.
  let small(body) = text(size: 0.65em, fill: luma(100), body)
  // What crosses each step; one width, so that the rings stay centred.
  let thing(pos, name, body) = node(pos,
    box(width: 2.6cm, align(center, text(size: 0.8em, fill: ink, body))),
    name: name, fill: white, stroke: 1pt + luma(170),
    corner-radius: 6pt, inset: 8pt, shape: fletcher.shapes.rect)
  let layer(name, note: none) = align(center, {
    text(weight: "bold", fill: ink, name)
    if note != none { [ #h(0.3em) #small(note)] }
  })
  set text(size: 18pt)
  diagram(
    spacing: (1.6cm, 1cm),
    edge-stroke: 1.5pt + ink,
    mark-scale: 80%,
    // The core, at the centre.
    node((0, 0), box(width: 3.6cm, align(center)[
      #text(weight: "bold", fill: ink)[Core] \
      #text(size: 0.65em, weight: "bold", fill: coral)[proved, pure]
    ]), name: <core>, fill: coral.lighten(88%), stroke: 1.5pt + coral,
      corner-radius: 6pt, inset: 10pt, shape: fletcher.shapes.rect),
    // What crosses each layer, on the way in and on the way out.
    thing((-2, 0), <in>)[clicks, messages],
    thing((-1, 0), <events>)[events],
    thing((1, 0), <decisions>)[decisions],
    thing((2, 0), <out>)[screen, rows, messages],
    // The layers' names, at the top of each ring.
    node((0, -0.9), layer([IO Shell]), name: <shell-name>),
    node((0, -1.6), layer([]), name: <world-name>),
    // Empty points below the core, so the rings are as deep as they are high.
    node((0, 0.9), [], name: <shell-floor>),
    node((0, 1.6), [], name: <world-floor>),
    // The rings, drawn behind, each around everything it contains.
    node(enclose: (<events>, <core>, <decisions>, <shell-name>, <shell-floor>),
      fill: luma(232), corner-radius: 14pt, inset: 12pt, layer: -1),
    node(enclose: (<in>, <out>, <world-name>, <world-floor>),
      fill: none, stroke: (paint: luma(150), dash: "dashed"),
      corner-radius: 20pt, inset: 20pt, layer: -2),
    edge(<in>, <events>, "-|>"),
    edge(<events>, <core>, "-|>"),
    edge(<core>, <decisions>, "-|>"),
    edge(<decisions>, <out>, "-|>"),
  )
})

== Where it fits best

#{
  // One row per family: its name, the step it repeats on one line, where
  // you meet it.
  let row(name, step, uses) = box(
    width: 100%,
    fill: luma(240),
    radius: 6pt,
    inset: 0.8em,
    grid(
      columns: (5.6cm, 11cm, 1fr),
      column-gutter: 0.6cm,
      align: left + horizon,
      text(size: 22pt, weight: "bold", fill: coral, name),
      small-code(raw(step, lang: "scala", block: true)),
      text(size: size-dense, uses),
    ),
  )
  align(horizon, stack(
    spacing: 0.5cm,
    row([Reducers], "(state, action) => state")[
      Forms, wizards, carts \ Undo / redo \ Redux, Elm, `useReducer`
    ],
    row([Event processors], "(state, event) => (state, decisions)")[
      Kafka consumers \ Event sourcing, ledgers \ Replay *is* a fold
    ],
    row([Actor behaviours], "(state, message) => (state, replies)")[
      Pekko / Akka `Behavior` \ Protocols, sessions \ Firmware state machines
    ],
  ))
}

== What it changes in your codebase

#set text(size: 18pt)

- *Tests* move to the shell
  around it
- *Review* moves to the specifications. Proofs are machine checked
- *CI* checks the proofs on every build
- *Rules* are written down. Invariants cannot rot

== Rocq-solid

#hero[Be the one who writes down *what must be true*.]

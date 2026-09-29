#import "/template/lib.typ": *

// Skeleton of the talk, extracted from its abstract:
// https://rebootwithai.digitregroup.io/programme/talk-3-t2
// Each `#todo[..]` marks content still to write.

#show: solid-theme.with(
  title: [Rocq-solid],
  subtitle: [A story about vericoding],
  institution: [Reboot with AI],
  date: datetime(year: 2026, month: 10, day: 1),
  slug: "rocq-solid",
)

= A story about Jack

== Meet Jack

- Full stack engineer at a fast-growing startup
- Twelve engineers, one product, a roadmap that doubles every quarter
- Frontend in the morning, database migrations after lunch, on call at night

== Jack loves Claude

#hero[Claude writes the feature.

Claude writes the tests.

CI is green. *Ship it.*]

== Six good months

- Three times as many pull requests merged per week
- Coverage above 90%, and climbing
- Not a single incident

#v(1em)
Jack reads every diff. Well, most of them. The tests are green anyway.

== What Jack did not see: a vacuous test

```ts
test("a refund never exceeds what was paid", async () => {
  const refunds = await db.refunds.findMany({ orderId: order.id });
  for (const refund of refunds) {
    expect(refund.amount).toBeLessThanOrEqual(order.paid);
  }
});
```

The fixture creates an order, but *no refund*. The loop never runs.

This test is green today, and will be green forever: *it cannot fail.*

== What Jack did not see: an assumption

```ts
type Order = {
  id: OrderId;
  paid: Money;
  refund?: Refund; // an order is refunded at most once
};

const refundable = (o: Order) => o.paid - (o.refund?.amount ?? 0);
```

Nobody said an order is refunded at most once.

Claude *guessed*, it read well, and the guess became the domain model.

== Then the product moves

- Support asks for *partial refunds*: one button, one click per refund
- Claude adds the button; each click stores a new `Refund`
- `order.refund` now points to the latest one
- `refundable` still subtracts a single refund: all tests pass

== Friday, 23:47

#hero[A customer notices the refund button *works more than once*.

By Monday morning: *€180,000* refunded, on *€40,000* of orders.]

== The post-mortem

- Every test was green
- Every pull request was reviewed and approved
- The code did exactly what it said

#v(1em)
#align(center)[*Nobody had written down what must be true.*]

= Doubting our guarantees

== The question

#hero[Tests and types are supposed to protect us from bugs.

*But who checks that those guarantees actually hold?*]

== What tests guarantee

- Examples, not properties
- #todo[a bug that gets through a green test suite]

== What types guarantee

- The shape of data, rarely its meaning
- #todo[an invariant the type system cannot see]

== The urgency

#hero[AI agents write code *faster than we can review it*.]

#todo[numbers or an anecdote: generated code volume vs. review capacity]

= Theorem provers

// These slides keep the section's name in the header and put their
// message in the body, large, where it is read. They tell one story:
// examples cannot establish a truth, a proof can, and the hard part is
// checking the proof, until a machine does it.
#let theorem-slide = message-slide.with(title: [Theorem provers])

// Evidence is not proof.
#theorem-slide(message: [906 million green tests. *Still false.*])[
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1.2cm,
    align: horizon,
    text(size: 22pt)[
      *Pólya, 1919*: up to any number, at least half of the numbers have an
      *odd* number of prime factors.

      #v(0.5em)
      Believed for *39 years*.
    ],
    {
      set text(font: "Fira Code", size: 15pt, fill: luma(230))
      let ok = text(fill: rgb("#7cc47f"))[✓]
      block(fill: rgb("#23373b"), radius: 6pt, inset: 1em, width: 100%)[
        #ok n = 2 \
        #ok n = 3 \
        #ok n = 4 \
        #text(fill: luma(140))[  … 906 150 250 more …] \
        #ok n = 906 150 256 \
        #text(fill: coral-light, weight: "bold")[✗ n = 906 150 257]
      ]
    },
  )

  #v(1em)
  #align(center)[
    _"Testing can show the presence of bugs, never their absence."_ \
    #text(size: 0.7em, fill: luma(120))[Edsger W. Dijkstra]
  ]
]

// A proof covers every case; checking one is the hard part.
#theorem-slide(message: [A proof covers every case. *Who checks it?*])[
  #let caption(body) = text(size: 14pt, fill: luma(120), body)
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 1.5cm,
    row-gutter: 0.6em,
    align: (x, y) => center + if y == 0 { horizon } else { top },
    rows: (3.2cm, auto),
    text(size: 20pt)[_"When there are disputes, we can simply say:
      *let us calculate*, to see who is right."_],
    text(size: 60pt, weight: "bold", fill: coral)[$1 + 1 = 2$],
    caption[Leibniz, 1685: the dream],
    caption[_Principia Mathematica_, 1910, page 379: the price],
  )

  #v(1em)
  #align(center, text(size: 22pt)[
    Every step is mechanical, and there are thousands:
    *a job for a machine*.
  ])
]

// The machine enters, and trust breaks.
#theorem-slide(message: [1976: the machine proves. *Nobody can check.*])[
  #grid(
    columns: (1.4fr, 1fr),
    column-gutter: 1.5cm,
    align: horizon,
    text(size: 22pt)[
      Any map can be coloured with *four colours*, no two neighbours alike.

      #v(0.5em)
      The proof takes *1,200 hours* of computation, and no human can
      follow it.

      #v(0.5em)
      Mathematicians split: *is it still a proof?*
    ],
    {
      let (r, b, g, y) = (
        coral.lighten(25%), rgb("#4a7c8c"), rgb("#7aa36b"), rgb("#e8b04a"),
      )
      let region(c, span: 1) = grid.cell(colspan: span, fill: c)[]
      grid(
        columns: (1fr,) * 4,
        rows: (2.2cm,) * 3,
        stroke: 3pt + white,
        region(r, span: 2), region(b), region(g),
        region(b), region(g, span: 2), region(y),
        region(y, span: 3), region(b),
      )
    },
  )
]

// The way out: a small, trusted checker.
#theorem-slide(message: [The way out: trust *only the checker*])[
  #align(center)[
    #{
      let ink = rgb("#23373b")
      let stage(name, note, fill: luma(240)) = box(
        width: 6cm,
        fill: fill,
        radius: 6pt,
        inset: (y: 0.8em),
        align(center)[
          #text(weight: "bold", fill: ink, name) \
          #text(size: 0.7em, fill: luma(100), note)
        ],
      )
      let arrow = text(size: 1.4em, fill: luma(150))[$arrow.long$]
      grid(
        columns: 5,
        column-gutter: 0.5em,
        align: horizon,
        stage[Anyone][a person, a program],
        arrow,
        stage[A proof][every step written out],
        arrow,
        stage(fill: coral.lighten(88%))[A small checker][short enough to read],
      )
    }

    #v(1.2em)
    #text(size: 22pt)[
      Who wrote the proof, and how, *no longer matters*.
    ]

    #text(size: 14pt, fill: luma(120))[Nicolaas de Bruijn, 1967]
  ]
]

// The payoff: what humans could not check, machines now do.
#theorem-slide(message: [Since then, machines check what *humans cannot*])[
  #align(center, grid(
    columns: (1fr,) * 3,
    column-gutter: 1cm,
    align: center + top,
    ..(
      ([1994], [The Pentium divides wrong, past every test:
        *\$475 million*. Chip makers start proving their arithmetic]),
      ([2005], [The four colour theorem, checked *end to end*.
        The debate is over]),
      ([2014], [Kepler's conjecture: the referees were _"99% certain"_.
        The machine is *sure*]),
    ).map(((year, body)) => [
      #text(size: 36pt, weight: "bold", fill: coral, year) \
      #text(size: 18pt, body)
    ])
  ))
]

#theorem-slide(message: [
  #box(baseline: 20%, image("/template/images/rocq-logo.svg", height: 1.2cm))
  #h(0.4em) 40 years of *machine-checked* proofs
])[
  #{
    let milestone(year, body) = align(center)[
      #text(weight: "bold", fill: coral, year)
      #box(width: 100%, height: 12pt, {
        place(horizon, line(length: 100%, stroke: 2pt + luma(210)))
        place(center + horizon, circle(radius: 5pt, fill: coral))
      })
      #text(size: 0.65em, body)
    ]
    grid(
      columns: (1fr,) * 6,
      align: top,
      milestone[1984][Coquand and Huet start it at Inria],
      milestone[1989][First release, named *Coq*],
      milestone[2005][*The four colour theorem*, checked],
      milestone[2006][CompCert, a C compiler proved correct],
      milestone[2013][ACM Software System Award],
      milestone[2025][Renamed *Rocq*, after Rocquencourt],
    )
  }

  #v(0.8em)
  #{
    let card(title, body) = box(
      width: 100%,
      height: 2.6cm,
      fill: luma(240),
      radius: 6pt,
      inset: 0.7em,
      align(center + horizon)[
        #text(weight: "bold", title) \
        #text(size: 0.7em, fill: luma(80), body)
      ],
    )
    grid(
      columns: (1fr,) * 3,
      column-gutter: 0.8cm,
      card[A small kernel][de Bruijn's checker: \ it re-checks every proof],
      card[Specs are types][a proof is a program \ of that type],
      card[Extraction][the proved program becomes \ OCaml, Haskell or Scheme],
    )
  }
]

#theorem-slide[
  #align(center + horizon, image("/template/images/lean-logo.svg", width: 35%))
]

#theorem-slide(message: [Many others, already *in production*])[
  #{
    let card(name, hook, body) = box(
      width: 100%,
      height: 3.9cm,
      fill: luma(240),
      radius: 6pt,
      inset: 0.8em,
      [
        #text(size: 1.1em, weight: "bold", fill: coral, name) \
        #text(weight: "bold", size: 0.8em, hook) \
        #v(-0.3em)
        #text(size: 0.65em, fill: luma(80), body)
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
]

= Vericoding

== Definition

- Making formal verification an *everyday tool*
- Taking proof assistants out of research labs
- Putting them in the hands of teams that ship to production

== The asymmetry

#hero[Writing a proof is hard.

Writing *what you want to prove* is much easier.]

== Who does what

- *You*: state what must be true (the specification)
- *The AI*: figures out why it holds (the proof)
- *Rocq*: checks the proof, without having to trust the AI

== Example: the specification

// Placeholder example, to replace with the talk's running example.
#rocq-file("/theories/Intro.v", lines: (20, 20))

#todo[the statement written by a human, readable without the proof]

== Example: the proof

#rocq-file("/theories/Intro.v", lines: (20, 26))

#todo[the proof produced by the agent, checked by Rocq]

== A new kind of guarantee

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1cm,
  [
    *Interfaces today*
    - A promise
    - Documented, tested, hoped for
  ],
  [
    *Proved interfaces*
    - A contract
    - Checked by the machine
  ],
)

= What to prove?

== Code worth proving

- *Invariants*
- *State machines*
- *Business rules* where a bug is not just an incident but can cost a lot

== Invariants

#todo[an invariant and its Rocq specification]

== State machines

#todo[a state machine: forbidden transitions, unreachable states]

== Business rules

#todo[a costly business rule: billing, permissions, quotas…]

== Where proof pays off, where it is not worth it

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1cm,
  [
    *Pays off*
    - #todo[criteria: cost of a bug, stability of the spec…]
  ],
  [
    *Not worth it*
    - #todo[criteria: fast-changing UI, throwaway code…]
  ],
)

= Shipping proved code

== From proof to production

#align(center + horizon)[
  #text(size: 24pt)[
    Rocq *extracts* the proved function to a real language.

    The rest of the app calls it *like any other library*.
  ]

  #v(1.2em)
  #{
    let ink = rgb("#23373b")
    let target(name, lang, fn) = box(
      width: 7cm,
      height: 2.4cm,
      fill: luma(240),
      radius: 6pt,
      align(center + horizon)[
        #text(weight: "bold", fill: ink, name) \
        #text(size: 0.7em, fill: luma(100), lang) \
        #text(size: 0.8em, fn)
      ],
    )
    grid(
      columns: 3,
      column-gutter: 0.8cm,
      target[The browser][React, via OCaml and Melange][`reducer`],
      target[A service][OCaml, in a Kafka consumer][`handle`],
      target[A microcontroller][the Encore! VM][`step`],
    )
  }
]

== Frontend: a reducer is a pure function

```ts
const [state, dispatch] = useReducer(reducer, initialState);
// reducer: (state, event) => state
```

- Same state, same event: *same next state*, and no side effects
- React counts on it: in Strict Mode, it calls your reducer *twice*

#v(0.5em)
#{
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
  align(center, grid(
    columns: 7,
    column-gutter: 0.3em,
    align: horizon,
    stage(fill: coral.lighten(88%))[Rocq][reducer + proofs],
    step[extraction],
    stage[OCaml][reducer + hook],
    step[Melange],
    stage[JavaScript][ES module],
    step[import],
    stage[React][imports the hook],
  ))
}

#v(0.8em)
*Rocqducers*:
#link("https://github.com/vbergeron/rocqducers")[github.com/vbergeron/rocqducers]

== Remember the refund button?

#rocq-file("/theories/AsyncButton.v", lines: (5, 15))

== Remember the refund button?

#rocq-file("/theories/AsyncButton.v", lines: (17, 20))

#v(1em)
A click while the request is in flight *does nothing*.

== The pick list: the model

#rocq-file("/theories/PickList.v", lines: (7, 9), size: 0.8em)

#v(0.5em)

#text(size: 0.8em)[
```rocq
reducer : state A -> event -> state A
init    : A -> list A -> state A
size    : state A -> nat
```
]

#v(0.5em)
- `init d rest` starts with `d` picked and every item of `rest` suggested
- `size s` counts the items, picked or suggested

== The pick list: the theorems

#rocq-file("/theories/PickList.v", lines: (71, 72), size: 0.8em)

Whatever the user clicks, *at least one item stays picked*.

#v(0.8em)

#rocq-file("/theories/PickList.v", lines: (106, 107), size: 0.8em)

Whatever the user clicks, *no item is ever lost or duplicated*.

== The pick list: the proof, one step

#rocq-file("/theories/PickList.v", lines: (54, 68), size: 0.75em)

== The pick list: the proof, any run

#[
  #show "reducer_keeps_picked": set text(weight: "bold")
  #rocq-file("/theories/PickList.v", lines: (70, 80), size: 0.8em)
]

#v(0.5em)
One step never empties the list; *by induction*, no run ever does.

== More frontend use cases

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1cm,
  [
    - *Undo / redo* for any reducer: Undo reverses Do, Redo reverses Undo
      (Rocqducers' `UndoList`)
    - *Branching history*: no edit is ever lost (`UndoTree`)
    - *Wizards and forms*: Submit is only reachable from a valid state
    - *Shopping cart*: the total is the sum of its lines, a promo code
      applies once
  ],
  [
    - *Permissions*: a button is shown exactly when the rule allows it
    - *Connection and auth*: no request leaves after logout
    - *Selection, pagination, drag and drop*: indices stay in bounds,
      a reorder is a permutation
    - *Optimistic updates*: a rollback restores exactly the previous state
  ],
)

== Event processing: an order is a list of events

#grid(
  columns: (1.1fr, 1fr),
  column-gutter: 1cm,
  [
    #rocq-file("/theories/Orders.v", lines: (7, 15), size: 0.75em)
    #rocq-file("/theories/Orders.v", lines: (23, 23), size: 0.75em)
    #rocq-file("/theories/Orders.v", lines: (37, 39), size: 0.75em)
  ],
  [
    #set text(size: 0.85em)
    - Every change is an *event*: a payment, a refund
    - The order is *replayed* from its events, one `handle` at a time
    - Queues deliver *at least once*: the same event can arrive *twice*
    - `handle` is a pure function: proved in Rocq, called by the consumer
  ],
)

== Event processing: Jack's refunds, proved

#rocq-file("/theories/Orders.v", lines: (51, 52), size: 0.8em)

Whatever events arrive, in whatever order: *never more refunded than paid*.

#v(0.8em)

#rocq-file("/theories/Orders.v", lines: (61, 62), size: 0.8em)

An event delivered twice is *counted once*.

#v(0.8em)
#align(center)[Friday, 23:47 *cannot happen*.]

== Shipping it: extraction to OCaml

#rocq-file("/extraction/OrdersExtraction.v", lines: (4, 7), size: 0.65em)

#grid(
  columns: (1fr, 1.1fr),
  column-gutter: 0.8cm,
  align: top,
  [
    #text(size: 0.6em, fill: luma(120))[Rocq: `theories/Orders.v`]
    #rocq-file("/theories/Orders.v", lines: (7, 15), size: 0.62em)
  ],
  [
    #text(size: 0.6em, fill: luma(120))[OCaml: `orders.mli`, written by `dune build`]
    #text(size: 0.62em)[
```ocaml
type event =
| Paid of int * int
| Refunded of int * int

type order = { seen : int list; paid : int; refunded : int }

val handle : order -> event -> order
val replay : event list -> order
```
    ]
  ],
)

== Shipping it: a Kafka consumer

#text(size: 0.7em)[
```ocaml
(* consumer.ml: the thin shell around the proved core *)
let rec loop state =
  match Kafka.consume ~timeout_ms:1000 topic partition with
  | Kafka.Message (_, _, offset, payload, _) ->
      let event = Codec.decode payload in          (* parse *)
      let next = Orders.handle state event in      (* proved *)
      Store.save next;                             (* persist *)
      Kafka.store_offset topic partition offset;   (* acknowledge *)
      loop next
  | Kafka.PartitionEnd _ -> loop state
```
]

#[
  #set text(size: 0.85em)
  - The shell only *parses*, *persists* and *acknowledges*: a few lines, reviewed by hand
  - A crash between `save` and the acknowledgement? Kafka delivers the event *again*:
    `delivered_twice_counted_once` says it is harmless
  - The business rule lives in `Orders.handle`, *proved*
]

== Embedded firmware: the device is a state machine

#grid(
  columns: (1.1fr, 1fr),
  column-gutter: 1cm,
  [
    #text(size: 0.75em)[
```rocq
step : state -> cmd -> state * resp

Record state := mk_state {
  pin : list nat;
  puk : list nat;
  tries : nat;       (* PIN attempts left *)
  puk_tries : nat;   (* PUK attempts left *)
  auth : bool        (* PIN verified *)
}.

Inductive cmd :=
| Verify (guess : list nat)
| Change (new_pin : list nat)
| Unblock (puk_guess new_pin : list nat)
| ...
```
    ]
  ],
  [
    #set text(size: 0.85em)
    - Your SIM card's PIN: 3 wrong tries and it blocks, the PUK unblocks it,
      10 wrong PUKs and the card is dead
    - The whole logic is *one pure function*, written and proved in Rocq
    - The chip only *reads commands* and *sends answers*
    - That same function *runs on the microcontroller*, in the *Encore!* VM:
      what runs is what was proved
  ],
)

#v(0.5em)
#text(size: 0.7em)[
  _From Rocq to Metal: A Pipeline for Formally Verified Microcontroller
  Firmware_:
  #link("https://arxiv.org/abs/2606.02651")[arXiv:2606.02651]
  · Encore!: #link("https://github.com/vbergeron/encore")[github.com/vbergeron/encore]
]

== Embedded firmware: what the card guarantees

#rocq-file("/theories/Pin.v", lines: (96, 97), size: 0.8em)

The card *only unlocks with the right PIN*.

#v(0.8em)

#rocq-file("/theories/Pin.v", lines: (109, 110), size: 0.8em)

A card blocked for good *stays blocked*, whatever you send it.

#v(0.8em)
#text(size: 0.7em)[
  PIN and PUK logic of a SIM card:
  #link("https://github.com/vbergeron/encore-benchmarks/tree/main/workloads/w4_pin")[encore-benchmarks, workload W4]
]

== What it changes in your architecture

#align(center)[*A proved core, a thin shell*: the same shape three times]

#v(0.3em)
#{
  set text(size: 0.8em)
  align(center, table(
    columns: 4,
    align: (left, left, center, left),
    stroke: none,
    inset: (x: 0.5em, y: 0.5em),
    fill: (x, y) => if x == 2 and y > 0 { coral.lighten(88%) },
    table.header[][*The shell reads*][*The core decides*][*The shell does*],
    [*Frontend*], [clicks], [`reducer`], [renders the new state],
    [*Service*], [Kafka messages], [`handle`], [saves, acknowledges],
    [*Firmware*], [commands from the phone], [`step`], [sends the answer],
  ))
}

#v(0.5em)
- The core is *pure*: state and event in, new state out. That is what makes it provable
- The shell does all the I/O, and *no business rule*: small enough to review by hand
- The boundary enforces itself: the core is generated code, with no access to the network,
  the disk or the clock

== What it changes in your codebase

- *Tests move to the shell*: a theorem covers every input of the core, tests cover the I/O
  around it
- *Review moves to the specification*: read the three lines of the theorem, not the
  proof. The AI writes the proof, Rocq checks it
- *CI checks the proofs on every build*: a broken proof fails the build like a failing test,
  and the shipped code is regenerated from the proved one
- *The rules are written down*: "never refund more than was paid" is in the codebase,
  checked, and cannot rot

== Rocq-solid

#hero[Be the one who writes down *what must be true*.]

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

== Evidence or proof

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1cm,
  align: top,
  [
    *A test is an experiment*
    - It checks a few cases, picked by hand
    - A thousand white swans do not prove that *all* swans are white
    - One black swan is enough to refute it
    - Empirical: it can *refute*, never *establish*
  ],
  [
    *A proof is a deduction*
    - From premises, by rules, to a conclusion
    - It covers *every* case, even infinitely many
    - Nothing to re-run: true today, true forever
    - Logical: as solid as its premises
  ],
)

== The limit of testing

#hero[_"Program testing can be used to show the presence of bugs,
but never to show their absence."_

#text(size: 0.6em)[Edsger W. Dijkstra, 1970]]

== Who checks the proof?

- A proof on paper is written by humans, and read by humans
- Hundreds of pages, a handful of referees, errors that survive for years
- Every step "obvious", until one of them is not

#v(1em)
#align(center)[The idea: make every step so small that *a machine can check it*.]

#let timeline(..rows) = {
  set text(size: 0.9em)
  grid(
    columns: (auto, 1fr),
    column-gutter: 1em,
    row-gutter: 0.7em,
    align: (right + top, left + top),
    ..rows.pos().map(((year, body)) => (
      text(weight: "bold", fill: coral, year),
      body,
    )).flatten(),
  )
}

== Mechanising reason: the dream

#timeline(
  ([c. 300 BC], [*Euclid*: a few axioms, and every theorem deduced from them]),
  ([1679], [*Leibniz* dreams of a calculus of thought: to settle a dispute,
    _"Calculemus!"_, let us calculate]),
  ([1879], [*Frege* writes the first fully formal logic]),
  ([1910], [*Whitehead and Russell* rebuild mathematics from logic:
    $1 + 1 = 2$ on page 379]),
  ([1931–36], [*Gödel, Church, Turing*: no machine can decide every truth.
    But *checking* a proof, step by step, is mechanical]),
)

== Mechanising proof: the machines

#timeline(
  ([1956], [A program proves 38 theorems of the _Principia_ on its own]),
  ([1967], [*de Bruijn*: a language in which a computer checks every step of a proof]),
  ([1969], [*Curry–Howard*: a proposition is a type, a proof is a program]),
  ([1976], [The four colour theorem: the first major proof that needs a computer.
    Mathematicians doubt it]),
  ([1994], [The Pentium division bug costs Intel \$475M:
    chip makers start proving their hardware]),
  ([2005], [The four colour theorem, checked end to end by a machine]),
  ([2014], [The Kepler conjecture: the referees were "99% sure", the machine is sure]),
  ([Today], [Mathematicians formalise research results; *AI writes proofs*]),
)

== Rocq

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1cm,
  align: top,
  [
    #set text(size: 0.8em)
    *When*
    - *1984*: Thierry Coquand and Gérard Huet start it at Inria Rocquencourt,
      on the Calculus of Constructions
    - *1989*: first release, named *Coq*
    - *1991*: inductive types, by Christine Paulin-Mohring
    - *2013*: ACM Software System Award
    - *2025*: renamed *Rocq*, for Rocquencourt. This talk runs on Rocq 9.1
  ],
  [
    #set text(size: 0.8em)
    *How*
    - A *functional language* with dependent types: a specification is a type,
      a proof is a program of that type
    - *Tactics*: you steer, Rocq builds the proof
    - A *small trusted kernel* re-checks every proof: no need to trust the
      tactics, nor whoever wrote them
    - *Extraction*: the proved program becomes OCaml, Haskell or Scheme
  ],
)

#v(0.5em)
#text(size: 0.75em)[
  *Proved with it*: CompCert, a C compiler proved correct · the four colour
  theorem · the Feit–Thompson theorem · Fiat Cryptography, the elliptic curve
  code running in Chrome
]

#empty-slide[
  #align(center + horizon, image("/template/images/lean-logo.svg", width: 55%))
]

== The others

#{
  set text(size: 0.75em)
  align(center, table(
    columns: 4,
    align: (left, left, left, left),
    stroke: none,
    inset: (x: 0.6em, y: 0.45em),
    fill: (x, y) => if y > 0 and calc.even(y) { luma(245) },
    table.header[*Tool*][*Since*][*Style*][*Known for*],
    [*Isabelle*], [1986, Cambridge and Munich], [higher-order logic],
      [seL4, an OS kernel proved correct],
    [*HOL Light*], [1994, John Harrison], [higher-order logic, tiny kernel],
      [Intel floating point, Kepler],
    [*ACL2*], [1990, Austin], [first-order logic on Lisp],
      [AMD and Intel arithmetic units],
    [*Mizar*], [1973, Poland], [set theory, readable proofs],
      [the oldest library of formal maths],
    [*Agda*], [2007, Chalmers], [dependent types],
      [programs that carry their proofs],
    [*F\**], [2011, Microsoft and Inria], [dependent types + SMT],
      [HACL\*: crypto in Firefox and Linux],
    [*Dafny*], [2009, Microsoft], [program verifier + SMT],
      [AWS's authorization engine],
    [*TLA+*], [1999, Leslie Lamport], [specifications of systems],
      [protocols at AWS and Azure],
  ))
}

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

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

== A story about Jack

#grid(
  columns: (2fr, 1fr),
  column-gutter: 1cm,
  align: horizon,
  [
    - Full stack developer at a small e-shop startup
    - Twelve engineers, one product, a roadmap that doubles every quarter
    - Frontend in the morning, database migrations after lunch, on call at night
  ],
  image("images/engineer.webp", width: 100%),
)

== A story about Jack

#hero[
  Claude writes the feature.

  Claude writes the tests.

  Jack *loves* Claude.
]

== A story about Jack

#grid(
  columns: (2fr, 1fr),
  column-gutter: 1cm,
  align: horizon,
  [
    The past 9 months have been a *blast*!
    - Three times as many pull requests merged per week
    - Coverage above 90%, and climbing

    #v(0.6em)
    Jack reads every diff. Well, most of them. _The tests are green anyway._
  ],
  image("images/klod.jpg", width: 100%),
)

== A story about Jack

#moment[Friday, 10h00][
  Product asks for *partial refunds*: one button, one click per refund.

  Claude does the job from the front to the DB.

  The tests are still green.
]

== A story about Jack

#moment[Friday, 22h57][
  A customer notices the refund button *works more than once*.
]

== A story about Jack

#moment[Monday, 08h43][
  *€180,000* refunded, on *€40* of orders.
]

== A story about Jack

```ts
type Order = {
  id: OrderId;
  paid: Money;
  refund?: Refund; // an order is refunded at most once
};

const refundable = (o: Order) => o.paid - (o.refund?.amount ?? 0);
```
/*
  "At most once" was never asked for. Claude *guessed*, it read well,
  and the guess became the domain model.
*/

== A story about Jack

```ts
test("a refund never exceeds what was paid", async () => {
  const refunds = await db.refunds.findMany({ orderId: order.id });
  for (const refund of refunds) {
    expect(refund.amount).toBeLessThanOrEqual(order.paid);
  }
});
```

== A story about Jack

*The post-mortem*
- Every test was green
- Every pull request was reviewed and approved
- The code did exactly what it said

#v(0.6em)
But nobody wrote down *what must be true*.

= It's all about proofs and trust

== Yes obviously some guys in the 17th century have thought about it

#grid(
  columns: (1fr, 2.5fr),
  rows: (1fr, 1fr),
  column-gutter: 1cm,
  align: left + horizon,

  [*Rationalists* \ #note[Descartes, Spinoza, Leibniz]],
  [
    - Knowledge comes from *reason* (innate ideas, deduction)
    - Model: *mathematical proof*
    - Limit: can pure reason tell us about the world?
  ],

  [*Empiricists* \ #note[Locke, Berkeley, Hume]],
  [
    - Knowledge comes from *experience* (mind as _tabula rasa_)
    - Model: *experience and deductions*
    - Limit: no amount of observation yields certainty
  ],
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
      *The question:* if no human can check it, is it still a proof? Do we _know_ the theorem, or do we _trust_ the machine?
    ]
  ],
  image("images/4color.png", width: 100%, height: 100%, fit: "contain"),
)

== Curry–Howard: proofs are programs

*Theorem (Curry 1934–1958, Howard 1969).*

Proofs in intuitionistic logic are exactly the programs of the typed $lambda$-calculus:
a proposition is provable if and only if the corresponding type has a program.

#v(0.6em)
#callout[*Checking a proof = checking a program's type.*]


// These slides keep the section's name in the header and put their
// message in the body, large, where it is read. They tell one story:
// examples cannot establish a truth, a proof can, and the hard part is
// checking the proof, until a machine does it.
#let theorem-slide = message-slide.with(title: [Theorem provers])

== Theorem Provers

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

== Who does what

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

== A new kind of guarantee

#align(center + horizon, image("images/sacrifice.jpg", height: 100%))

= Shipping proved code

== From proof to production

#hero[
  Rocq *extracts* the proved function to a real language.

  The rest of the app calls it *like any other library*.
]

== Event processing: an order is a list of events

#grid(
  columns: (1.4fr, 1fr),
  column-gutter: 0.6cm,
  align: horizon,
  rocq-file("/theories/Orders.v", lines: ((7, 15), (23, 23), (37, 39)), size: code-small),
  [
    #set text(size: size-dense)
    - Every change is an *event*: a payment, a refund
    - The order is *replayed* from its events, one `handle` at a time
    - Queues deliver *at least once*: the same event can arrive *twice*
    - `handle` is a pure function: proved in Rocq, called by the consumer
  ],
)

== Event processing: Jack's refunds, proved

#rocq-file("/theories/Orders.v", lines: (51, 52))

Whatever events arrive, in whatever order: *never more refunded than paid*.

#v(0.6em)

#rocq-file("/theories/Orders.v", lines: (61, 62))

An event delivered twice is *counted once*.

#v(0.6em)
#align(center)[Friday, 22h57 *cannot happen*.]

== Shipping it: extraction to OCaml

#rocq-file("/extraction/OrdersExtraction.v", lines: (4, 7), size: code-small)

#grid(
  columns: (1.05fr, 1fr),
  column-gutter: 0.6cm,
  align: top,
  [
    #note[Rocq: `theories/Orders.v`]
    #rocq-file("/theories/Orders.v", lines: (7, 15), size: code-small)
  ],
  small-code[
    #note[OCaml: `orders.mli`, written by `dune build`]
```ocaml
type event =
| Paid of int * int
| Refunded of int * int

type order = {
  seen : int list;
  paid : int;
  refunded : int;
}

val handle : order -> event -> order
val replay : event list -> order
```
  ],
)

== Shipping it: a Kafka consumer

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

#[
  #set text(size: size-dense)
  - The shell only *parses*, *persists* and *acknowledges*: a few lines, reviewed by hand
  - A crash between `save` and the acknowledgement? Kafka delivers the event *again*:
    `delivered_twice_counted_once` says it is harmless
  - The business rule lives in `Orders.handle`, *proved*
]


== Frontend: a reducer is a pure function

```ts
const [state, dispatch] = useReducer(reducer, initialState);
// reducer: (state, event) => state
```

- Same state, same event: *same next state*, and no side effects
- React counts on it: in Strict Mode, it calls your reducer *twice*

#v(0.6em)
#{
  let stage(name, note, fill: luma(240)) = box(
    width: 4.4cm,
    fill: fill,
    radius: 6pt,
    inset: (y: 0.6em),
    align(center)[
      #text(weight: "bold", fill: ink, name) \
      #text(size: size-note, fill: luma(100), note)
    ],
  )
  let step(label) = align(center)[
    #text(size: size-note, style: "italic", fill: luma(120), label) \
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

#v(0.6em)
#align(center, note[*Rocqducers*:
  #link("https://github.com/vbergeron/rocqducers")[github.com/vbergeron/rocqducers]])

== Remember the refund button?

#rocq-file("/theories/AsyncButton.v", lines: (5, 15))

== Remember the refund button?

#rocq-file("/theories/AsyncButton.v", lines: (17, 20))

#v(0.6em)
A click while the request is in flight *does nothing*.

== The pick list: the model

#rocq-file("/theories/PickList.v", lines: (7, 9))

```rocq
reducer : state A -> event -> state A
init    : A -> list A -> state A
size    : state A -> nat
```

#v(0.6em)
- `init d rest` starts with `d` picked and every item of `rest` suggested
- `size s` counts the items, picked or suggested

== The pick list: the theorems

#rocq-file("/theories/PickList.v", lines: (71, 72))

Whatever the user clicks, *at least one item stays picked*.

#v(0.6em)

#rocq-file("/theories/PickList.v", lines: (106, 107))

Whatever the user clicks, *no item is ever lost or duplicated*.

== The pick list: the proof, one step

#rocq-file("/theories/PickList.v", lines: (54, 68))

== The pick list: the proof, any run

#[
  #show "reducer_keeps_picked": set text(weight: "bold")
  #rocq-file("/theories/PickList.v", lines: (70, 80))
]

#v(0.6em)
One step never empties the list; *by induction*, no run ever does.

== More frontend use cases

#set text(size: 18pt)

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

== Embedded firmware: the device is a state machine

#grid(
  columns: (1fr, 1fr),
  column-gutter: 0.6cm,
  align: horizon,
  small-code[
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
  ],
  [
    #set text(size: size-dense)
    - Your SIM card's PIN: 3 wrong tries and it blocks, the PUK unblocks it,
      10 wrong PUKs and the card is dead
    - The whole logic is *one pure function*, written and proved in Rocq
    - The chip only *reads commands* and *sends answers*
    - That same function *runs on the microcontroller*, in the *Encore!* VM:
      what runs is what was proved
  ],
)

#v(0.6em)
#note[
  _From Rocq to Metal: A Pipeline for Formally Verified Microcontroller
  Firmware_:
  #link("https://arxiv.org/abs/2606.02651")[arXiv:2606.02651]
  · Encore!: #link("https://github.com/vbergeron/encore")[github.com/vbergeron/encore]
]

== Embedded firmware: what the card guarantees

#rocq-file("/theories/Pin.v", lines: (96, 97))

The card *only unlocks with the right PIN*.

#v(0.6em)

#rocq-file("/theories/Pin.v", lines: (109, 110))

A card blocked for good *stays blocked*, whatever you send it.

#v(0.6em)
#note[
  PIN and PUK logic of a SIM card:
  #link("https://github.com/vbergeron/encore-benchmarks/tree/main/workloads/w4_pin")[encore-benchmarks, workload W4]
]

== What it changes in your architecture

#align(center)[*A proved core, a thin shell*: the same shape three times]

#v(0.3em)
#{
  set text(size: size-dense)
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

#v(0.6em)
#set text(size: 18pt)
- The core is *pure*: state and event in, new state out. That is what makes it provable
- The shell does all the I/O, and *no business rule*: small enough to review by hand
- The boundary enforces itself: the core is generated code, with no access to the network,
  the disk or the clock

== What it changes in your codebase

#set text(size: 18pt)

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

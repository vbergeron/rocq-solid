#import "/template/lib.typ": *

// Skeleton of the talk, extracted from its abstract:
// https://rebootwithai.digitregroup.io/programme/talk-3-t2
// Each `#todo[..]` marks content still to write.

#show: solid-theme.with(
  title: [Rocq-solid],
  subtitle: [A story about vericoding],
  institution: [Reboot with AI],
  // date: datetime(year: 2026, month: 10, day: 1),
  slug: "rocq-solid",
  links: (
    (url: "https://github.com/vbergeron/rocq-solid", label: "Sources"),
    (url: "https://rocq-prover.org", label: "Rocq"),
  ),
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

= Vericoding

== Definition

- Making formal verification an *everyday tool*
- Taking proof assistants out of research labs
- Putting them in the hands of teams that ship to production

== Rocq in one slide

- #todo[proof assistant, trusted kernel, extraction]
- #todo[quick history: Coq becomes Rocq, CompCert, etc.]

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

#rocq-file("/theories/Intro.v", lines: (20, 25))

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

#todo[extraction: from Rocq to a production language]

== Backend

#todo[a service whose business core is extracted from Rocq]

== Frontend: a reducer is a pure function

```ts
const [state, dispatch] = useReducer(reducer, initialState);
// reducer: (state, event) => state
```

- A reducer is a *pure function*
- #link("https://github.com/vbergeron/rocqducers")[Rocqducers]: the reducer
  is written and proved in Rocq, extracted to OCaml, compiled to JS by
  Melange, then handed to `useReducer`

== Remember the refund button?

#rocq-file("/theories/AsyncButton.v", lines: (5, 15))

== Remember the refund button?

#rocq-file("/theories/AsyncButton.v", lines: (17, 20))

#v(1em)
A click while the request is in flight *does nothing*.

== The pick list: the statement

#rocq-file("/theories/PickList.v", lines: (7, 10), size: 0.8em)

#rocq-file("/theories/PickList.v", lines: (60, 62), size: 0.8em)

#v(0.5em)
Replay *any* sequence of dispatched events: at least one item stays picked.

== The pick list: the reducer

#rocq-file("/theories/PickList.v", lines: (25, 39), size: 0.8em)

== The pick list: the proof, one step

#rocq-file("/theories/PickList.v", lines: (44, 58), size: 0.75em)

== The pick list: the proof, any run

#rocq-file("/theories/PickList.v", lines: (60, 68), size: 0.8em)

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

== Event-driven systems

#todo[event handlers and projection invariants]

== Embedded firmware

#todo[proved code on a constrained target]

== What it changes in your architecture

- #todo[a proved core, an unproved shell]
- #todo[where to draw the boundary, how to enforce it]

== What it changes in your codebase

- #todo[fewer defensive tests, reviews focused on specifications]
- #todo[CI: proofs are checked on every build]

= Conclusion

== Takeaways

- #todo[three ideas to take home]

== Rocq-solid

#hero[We started by doubting our guarantees.

We leave with foundations *as solid as a Rocq*.]

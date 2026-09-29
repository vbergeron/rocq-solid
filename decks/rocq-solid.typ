#import "/template/lib.typ": *

// Skeleton of the talk, extracted from its abstract:
// https://rebootwithai.digitregroup.io/programme/talk-3-t2
// Each `#todo[..]` marks content still to write.

#show: solid-theme.with(
  title: [Rocq-solid],
  subtitle: [A story about vericoding],
  institution: [Reboot with AI],
  // date: datetime(year: 2026, month: 10, day: 1),
  // slug: "rocq-solid",  // adds a "Follow along" QR slide, see template/lib.typ
  links: (
    (url: "https://github.com/vbergeron/rocq-solid", label: "Sources"),
    (url: "https://rocq-prover.org", label: "Rocq"),
  ),
)

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

== Frontend

#todo[proved client-side state logic]

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

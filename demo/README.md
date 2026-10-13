# Live demo: prove it, then ship it to Scala

An AI agent proves a theorem about the refund handler of
`demo/theories/Redelivery.v` through the [boulodrome](https://github.com/vbergeron/boulodrome)
MCP server, then the handler is extracted to Scala 3 with
[rocq-extraction-scala](https://github.com/vbergeron/rocq-extraction-scala)
and run on an endless Kafka-like topic.

## The theorems

Both are stated, and left `Admitted`, for the agent to prove live.

**`demo/theories/Redelivery.v`, `redelivery_is_harmless`**: Kafka delivers at
least once; events already handled can come back later, any number of
times, in any order, mixed with new ones, and the order is the same as
if they never had.

```rocq
Theorem redelivery_is_harmless : forall before redelivered after : list event,
  incl redelivered before ->
  replay (before ++ redelivered ++ after) = replay (before ++ after).
```

**`demo/theories/Forever.v`, `always_solvent`**: the stream version. A
consumer never sees the whole list, it sees an endless stream; `states`
is the order after each event, forever, and it never refunds more than
was paid.

```rocq
Theorem always_solvent : forall s : Stream event,
  ForAll solvent (states empty s).
```

Neither falls to a single tactic: the first needs a few auxiliary lemmas
and an induction with the right generalization, the second a coinduction
(`cofix`), with Rocq's guardedness check waiting at `Qed`.

## Two toolchains

| Step | Rocq | Why |
|---|---|---|
| Proving (boulodrome) | 9.1 | boulodrome depends on `coq-lsp` 0.2.5+9.1 |
| Extracting to Scala | 9.4 (`master`) | the plugin needs the extraction API of rocq-prover/rocq#22541 |

The `.v` files build with both. Proofs live in the 9.1 switch; only
`dune build @extract` needs the master one:

```sh
opam pin add rocq-runtime git+https://github.com/rocq-prover/rocq#master
opam pin add rocq-core    git+https://github.com/rocq-prover/rocq#master
opam pin add rocq-stdlib  git+https://github.com/rocq-prover/stdlib#master
opam pin add rocq-extraction-scala git+https://github.com/vbergeron/rocq-extraction-scala
```

Scala runs through [scala-cli](https://scala-cli.virtuslab.org).

## Running it

**1. Register boulodrome**: `.mcp.json` at the repository root already
does it for Claude Code (approve it on the first `claude` start). It runs
boulodrome from the `rocq-demo` opam switch, so only `opam` needs to be on
PATH:

```json
{ "mcpServers": { "boulodrome": { "command": "opam",
  "args": ["exec", "--switch=rocq-demo", "--", "boulodrome", "demo"] } } }
```

It finds the `Demo` theory from `demo/theories/dune` by itself.

**2. Ask the agent**, for instance:

> Prove `redelivery_is_harmless` in `demo/theories/Redelivery.v` with the
> boulodrome tools. Do not change the statement or the definitions above it;
> add helper lemmas between them and the theorem if you need them. Splice the proof in with
> `rocq_proof_script` and finish with `rocq_verify`.

Then the same for `always_solvent` in `demo/theories/Forever.v`.

**3. Check it**: `dune build` in `demo/`.

**4. Ship it** (master switch):

```sh
(cd demo && dune build @extract)   # writes demo/scala/Refunds.scala
scala-cli run demo/scala            # the consumer on an endless topic
```

```
replay: Mk_order(List(3, 2, 1),100,30)
states: paid=0 refunded=0
states: paid=100 refunded=0
states: paid=100 refunded=30
states: paid=100 refunded=30
...
```

`replay` gets the refund of 30 twice and a refund of 90 that would
overdraw: the duplicate is ignored, the overdraw refused. The endless
topic pays 100, then delivers the same refund of 30 forever: it is
counted once.

`Refunds.scala` holds `handle`, `replay` and `states` as plain typed
methods, `def handle(o: Order)(e: Event): Order`: `ExtrScalaNatBigInt`
maps money to `BigInt`, lists to `List` and booleans to `Boolean`, and
`Set Extraction Scala Pure Functions` prints function types with pure
arrows (`BigInt -> BigInt -> Boolean`), hence the `-experimental` flag in
`Main.scala`. The stream is a lazy `RocqLazy` thunk, and the proofs
are erased.

**5. Reset** after a rehearsal: `git checkout demo/theories`.

## Known limits

- `Redelivery.v` compares with Stdlib's `PeanoNat.Nat.eqb` and `leb`, copies
  of the Corelib functions `ExtrScalaNatBigInt` maps, so
  `RefundsExtraction.v` maps those two itself; without it they extract
  as recursive functions on `BigInt`.
- For a real consumer, extract `handle` only and let fs2 stream it:
  `kafkaEvents.scan(empty)(handle)` is `states empty`.

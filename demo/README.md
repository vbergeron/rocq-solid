# Live demo: prove it, then ship it to Scala

An AI agent proves a theorem about the refund handler of
`theories/Orders.v` through the [boulodrome](https://github.com/vbergeron/boulodrome)
MCP server, then the handler is extracted to Scala 3 with
[rocq-extraction-scala](https://github.com/vbergeron/rocq-extraction-scala)
and run on an endless Kafka-like topic.

## The theorems

Both are stated, and left `Admitted`, for the agent to prove live.

**`theories/Redelivery.v`, `redelivery_is_harmless`**: Kafka delivers at
least once; events already handled can come back later, any number of
times, in any order, mixed with new ones, and the order is the same as
if they never had.

```rocq
Theorem redelivery_is_harmless : forall before redelivered after : list event,
  incl redelivered before ->
  replay (before ++ redelivered ++ after) = replay (before ++ after).
```

**`theories/Forever.v`, `always_solvent`**: the stream version. A
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
`demo/extract.sh` needs the master one:

```sh
opam pin add rocq-runtime git+https://github.com/rocq-prover/rocq#master
opam pin add rocq-core    git+https://github.com/rocq-prover/rocq#master
opam pin add rocq-stdlib  git+https://github.com/rocq-prover/stdlib#master
opam pin add rocq-extraction-scala git+https://github.com/vbergeron/rocq-extraction-scala
```

Scala runs through [scala-cli](https://scala-cli.virtuslab.org).

## Running it

**1. Register boulodrome** in `.mcp.json` at the repository root (Claude
Code), from the 9.1 switch:

```json
{ "mcpServers": { "boulodrome": { "command": "boulodrome", "args": ["."] } } }
```

It finds the `Solid` theory from `theories/dune` by itself.

**2. Ask the agent**, for instance:

> Prove `redelivery_is_harmless` in `theories/Redelivery.v` with the
> boulodrome tools. Do not change the statement or `theories/Orders.v`;
> add helper lemmas above it if you need them. Splice the proof in with
> `rocq_proof_script` and finish with `rocq_verify`.

Then the same for `always_solvent` in `theories/Forever.v`.

**3. Check it** the usual way: `mise run build`.

**4. Ship it** (master switch):

```sh
demo/extract.sh                 # writes demo/scala/Refunds.scala
scala-cli run demo/scala        # the consumer on an endless topic
```

```
paid=0 refunded=0
paid=100 refunded=0
paid=100 refunded=30
paid=100 refunded=30
...
```

The topic pays 100, then delivers the same refund of 30 forever: it is
counted once. `Refunds.scala` holds `handle`, `replay` and `states`,
money as `BigInt`, and the stream as a lazy `RocqLazy` thunk; the proofs
are erased.

**5. Reset** after a rehearsal: `git checkout theories/Redelivery.v theories/Forever.v`.

## Known limits

- Mapping `bool` or `list` onto Scala's `Boolean` and `List` with
  `Extract Inductive` produces Scala that does not compile, so they stay
  extracted ADTs (`True()`, `Cons(..)`); `nat` to `BigInt` works.
- The stream constructor is renamed `Cons0` in Scala, since the list one
  already took `Cons`.
- For a real consumer, extract `handle` only and let fs2 stream it:
  `kafkaEvents.scan(empty)(handle)` is `states empty`.

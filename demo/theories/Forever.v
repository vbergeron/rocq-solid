(* Live demo, stream version: a Kafka consumer never sees the whole list
   of events, it sees an infinite stream. [states] is the order after
   each event, forever; the theorem says it never refunds more than was
   paid, at any point. Its proof is left to the AI agent, live, through
   the boulodrome MCP server; demo/README.md runs the demo. *)
From Stdlib Require Import Streams.
From Demo Require Import Redelivery.

(* The order, then the order after each event of an endless stream. *)
CoFixpoint states (o : order) (s : Stream event) : Stream order :=
  Cons o (states (handle o (hd s)) (tl s)).

(* The order at the head of the stream has not refunded more than paid. *)
Definition solvent (os : Stream order) : Prop :=
  refunded (hd os) <= paid (hd os).

(* The consumer may run forever: it is solvent at every point. *)
Theorem always_solvent : forall s : Stream event,
  ForAll solvent (states empty s).
Proof.
Admitted.

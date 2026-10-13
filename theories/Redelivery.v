(* Live demo: the order handler of theories/Orders.v under at-least-once
   delivery. Kafka may hand the consumer an event it already handled,
   later, any number of times, in any order, mixed with new events. The
   theorem below says none of it changes the order. Its proof is left to
   the AI agent, live, through the boulodrome MCP server; demo/README.md
   runs the demo, then extracts the handler to Scala. *)
From Stdlib Require Import List.
Import ListNotations.
From Solid Require Import Orders.

Theorem redelivery_is_harmless : forall before redelivered after : list event,
  incl redelivered before ->
  replay (before ++ redelivered ++ after) = replay (before ++ after).
Proof.
Admitted.

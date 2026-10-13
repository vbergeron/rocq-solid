(* Live demo: the order handler under at-least-once delivery. Kafka may
   hand the consumer an event it already handled, later, any number of
   times, in any order, mixed with new events. The theorem below says none
   of it changes the order. Its proof is left to the AI agent, live,
   through the boulodrome MCP server; demo/README.md runs the demo.

   Self-contained: the handler is copied from theories/Orders.v so this
   file depends on Stdlib only. *)
From Stdlib Require Import Arith List.
Import ListNotations.

Inductive event :=
| Paid (id amount : nat)
| Refunded (id amount : nat).

Record order := mk_order {
  seen : list nat;   (* ids already handled *)
  paid : nat;
  refunded : nat
}.

Definition event_id (e : event) : nat :=
  match e with Paid i _ | Refunded i _ => i end.

Definition already_seen (o : order) (e : event) : bool :=
  existsb (Nat.eqb (event_id e)) (seen o).

Definition handle (o : order) (e : event) : order :=
  if already_seen o e then o (* delivered twice: ignore it *)
  else
    let seen' := event_id e :: seen o in
    match e with
    | Paid _ n => mk_order seen' (paid o + n) (refunded o)
    | Refunded _ n =>
        if refunded o + n <=? paid o
        then mk_order seen' (paid o) (refunded o + n)
        else mk_order seen' (paid o) (refunded o) (* refused *)
    end.

Definition empty : order := mk_order [] 0 0.

(* The order, rebuilt from its events. *)
Definition replay (events : list event) : order :=
  fold_left handle events empty.

Theorem redelivery_is_harmless : forall before redelivered after : list event,
  incl redelivered before ->
  replay (before ++ redelivered ++ after) = replay (before ++ after).
Proof.
Admitted.

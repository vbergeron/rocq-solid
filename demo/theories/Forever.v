(* Live demo, stream version: a Kafka consumer never sees the whole list
   of events, it sees an infinite stream. [states] is the order after
   each event, forever; the theorem says it never refunds more than was
   paid, at any point. Its proof is left to the AI agent, live, through
   the boulodrome MCP server; demo/README.md runs the demo. *)
From Stdlib Require Import Streams Arith Lia.
From Demo Require Import Redelivery.

(* The order, then the order after each event of an endless stream. *)
CoFixpoint states (o : order) (s : Stream event) : Stream order :=
  Cons o (states (handle o (hd s)) (tl s)).

(* The order at the head of the stream has not refunded more than paid. *)
Definition solvent (os : Stream order) : Prop :=
  refunded (hd os) <= paid (hd os).

(* One event never pushes the refunds above the payments. *)
Lemma handle_keeps_refunds : forall o e,
  refunded o <= paid o -> refunded (handle o e) <= paid (handle o e).
Proof.
  intros o e H. unfold handle.
  destruct (already_seen o e); [exact H |].
  destruct e as [i n | i n]; cbn; [lia |].
  destruct (refunded o + n <=? paid o) eqn:E; cbn; [apply Nat.leb_le in E |]; lia.
Qed.

(* From any solvent order, the stream of orders stays solvent. *)
Lemma states_solvent : forall s o,
  refunded o <= paid o -> ForAll solvent (states o s).
Proof.
  cofix CIH. intros s o H. constructor.
  - exact H.
  - cbn. apply CIH, handle_keeps_refunds, H.
Qed.

(* The consumer may run forever: it is solvent at every point. *)
Theorem always_solvent : forall s : Stream event,
  ForAll solvent (states empty s).
Proof.
  intro s. apply states_solvent. cbn. lia.
Qed.

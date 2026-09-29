(* Jack's refunds as event processing: an order is rebuilt from its events,
   payments and refunds, and a queue may deliver the same event twice.
   decks/rocq-solid.typ shows parts of this file. *)
From Stdlib Require Import Arith List Lia.
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

(* One event never pushes the refunds above the payments. *)
Lemma handle_keeps_refunds : forall o e,
  refunded o <= paid o -> refunded (handle o e) <= paid (handle o e).
Proof.
  intros o e H. unfold handle.
  destruct (already_seen o e); [exact H|].
  destruct e as [i n | i n]; cbn; [lia|].
  destruct (refunded o + n <=? paid o) eqn:E; cbn; [apply Nat.leb_le in E|]; lia.
Qed.

Theorem never_refund_more_than_paid : forall (events : list event),
  refunded (replay events) <= paid (replay events).
Proof.
  intro events. unfold replay.
  assert (H : refunded empty <= paid empty) by (cbn; lia).
  revert H. generalize empty as o.
  induction events as [| e es IH]; intros o H; cbn; [exact H|].
  apply IH, handle_keeps_refunds, H.
Qed.

Theorem delivered_twice_counted_once : forall (o : order) (e : event),
  handle (handle o e) e = handle o e.
Proof.
  intros o e. unfold handle at 2 3.
  destruct (already_seen o e) eqn:E.
  - unfold handle. rewrite E. reflexivity.
  - assert (Hid : forall o', seen o' = event_id e :: seen o -> already_seen o' e = true).
    { intros o' Hs. unfold already_seen. rewrite Hs. cbn. rewrite Nat.eqb_refl. reflexivity. }
    unfold handle. destruct e as [i n | i n].
    + rewrite Hid; reflexivity.
    + destruct (refunded o + n <=? paid o); rewrite Hid; reflexivity.
Qed.

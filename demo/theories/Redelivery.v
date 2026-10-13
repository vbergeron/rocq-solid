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

(* [already_seen] is membership of the event's id in [seen]. *)
Lemma already_seen_In : forall o e,
  already_seen o e = true <-> In (event_id e) (seen o).
Proof.
  intros o e. unfold already_seen. rewrite existsb_exists. split.
  - intros [x [Hx Hq]]. apply Nat.eqb_eq in Hq. subst x. exact Hx.
  - intros H. exists (event_id e). split; [exact H | apply Nat.eqb_refl].
Qed.

(* Handling an event forgets no id... *)
Lemma handle_seen_incl : forall o e, incl (seen o) (seen (handle o e)).
Proof.
  intros o e. unfold handle.
  destruct (already_seen o e); [apply incl_refl |].
  destruct e as [i n | i n]; cbn; [| destruct (refunded o + n <=? paid o)];
    cbn; apply incl_tl, incl_refl.
Qed.

(* ...and remembers its own. *)
Lemma handle_seen_id : forall o e, In (event_id e) (seen (handle o e)).
Proof.
  intros o e. unfold handle.
  destruct (already_seen o e) eqn:E; [apply already_seen_In; exact E |].
  destruct e as [i n | i n]; cbn; [| destruct (refunded o + n <=? paid o)];
    cbn; left; reflexivity.
Qed.

Lemma fold_seen_incl : forall l o,
  incl (seen o) (seen (fold_left handle l o)).
Proof.
  induction l as [| e l IH]; intros o; cbn; [apply incl_refl |].
  eapply incl_tran; [apply handle_seen_incl | apply IH].
Qed.

(* After a list of events, every one of them has been seen. *)
Lemma fold_seen_all : forall l o e,
  In e l -> In (event_id e) (seen (fold_left handle l o)).
Proof.
  induction l as [| a l IH]; intros o e H; [destruct H |].
  cbn. destruct H as [<- | H].
  - apply fold_seen_incl, handle_seen_id.
  - apply IH, H.
Qed.

(* Events already seen change nothing. *)
Lemma fold_already_seen : forall l o,
  (forall e, In e l -> In (event_id e) (seen o)) -> fold_left handle l o = o.
Proof.
  induction l as [| a l IH]; intros o H; cbn; [reflexivity |].
  assert (Ha : handle o a = o).
  { unfold handle.
    rewrite (proj2 (already_seen_In o a)) by (apply H; left; reflexivity).
    reflexivity. }
  rewrite Ha. apply IH. intros e He. apply H. right. exact He.
Qed.

(* Replaying [before] marks every event of [redelivered] as seen, so they
   are all ignored. *)
Theorem redelivery_is_harmless : forall before redelivered after : list event,
  incl redelivered before ->
  replay (before ++ redelivered ++ after) = replay (before ++ after).
Proof.
  intros before redelivered after H. unfold replay.
  rewrite !fold_left_app. f_equal.
  apply fold_already_seen. intros e He.
  apply fold_seen_all, H, He.
Qed.

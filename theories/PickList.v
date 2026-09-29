(* The pick list of Rocqducers (github.com/vbergeron/rocqducers): items
   move between [picked] and [suggestions], and at least one item must
   always stay picked. decks/rocq-solid.typ shows parts of this file. *)
From Stdlib Require Import List Lia.
Import ListNotations.

Record state (A : Type) := mk { picked : list A; suggestions : list A }.

Inductive event := DoPick (i : nat) | DoUnpick (i : nat).

(* Let Rocq infer the item type [A]: write [picked s], not [picked A s]. *)
Arguments mk {A}. Arguments picked {A}. Arguments suggestions {A}.

Fixpoint remove_at {A} (i : nat) (l : list A) : list A :=
  match l, i with
  | [], _ => []
  | _ :: t, O => t
  | h :: t, S i' => h :: remove_at i' t
  end.

Definition do_pick {A} (s : state A) (i : nat) : state A :=
  match nth_error (suggestions s) i with
  | None => s
  | Some x => mk (x :: picked s) (remove_at i (suggestions s))
  end.

Definition do_unpick {A} (s : state A) (i : nat) : state A :=
  match picked s with
  | [] | [_] => s (* never unpick the last item *)
  | _ =>
    match nth_error (picked s) i with
    | None => s
    | Some x => mk (remove_at i (picked s)) (x :: suggestions s)
    end
  end.

Definition reducer {A} (s : state A) (e : event) : state A :=
  match e with
  | DoPick i => do_pick s i
  | DoUnpick i => do_unpick s i
  end.

(* The initial state: one item picked, the others suggested. *)
Definition init {A} (default : A) (rest : list A) : state A :=
  mk [default] rest.

(* The number of items, picked or not. *)
Definition size {A} (s : state A) : nat :=
  length (picked s) + length (suggestions s).

Lemma remove_at_two {A} (a b : A) t i : remove_at i (a :: b :: t) <> [].
Proof. destruct i; simpl; discriminate. Qed.

(* One step: no single event empties [picked]. *)
Lemma reducer_keeps_picked : forall A (s : state A) e,
  picked s <> [] -> picked (reducer s e) <> [].
Proof.
  intros A [ps ss] [i | i] H; simpl in *.
  - (* DoPick: an item is added to [picked] *)
    unfold do_pick; simpl.
    destruct (nth_error ss i); simpl; [discriminate | exact H].
  - (* DoUnpick: [picked] has 0, 1 or at least 2 items *)
    unfold do_unpick; simpl.
    destruct ps as [| a [| b t]]; simpl; try exact H.
    destruct (nth_error (a :: b :: t) i); simpl.
    + apply remove_at_two.
    + exact H.
Qed.

(* Any run: whatever the user clicks, [picked] is never empty. *)
Theorem picked_never_empty : forall A (d : A) rest events,
  picked (fold_left reducer events (init d rest)) <> [].
Proof.
  intros A d rest events.
  assert (H : picked (init d rest) <> []) by (simpl; discriminate).
  revert H. generalize (init d rest) as s.
  induction events as [| e es IH]; intros s H; simpl.
  - exact H.
  - apply IH, reducer_keeps_picked, H.
Qed.

Lemma remove_at_length : forall A i (l : list A),
  i < length l -> length (remove_at i l) = length l - 1.
Proof.
  intros A i l. revert i.
  induction l as [| h t IH]; intros [| i] Hi; simpl in *; try lia.
  rewrite IH by lia. lia.
Qed.

(* One step: no single event adds or loses an item. *)
Lemma size_step : forall A (s : state A) e, size (reducer s e) = size s.
Proof.
  intros A [ps ss] [i | i]; unfold size; simpl.
  - unfold do_pick; simpl.
    destruct (nth_error ss i) eqn:Hn; simpl; [| reflexivity].
    assert (i < length ss) by (apply nth_error_Some; congruence).
    rewrite remove_at_length by assumption. lia.
  - unfold do_unpick; simpl.
    destruct ps as [| a [| b t]]; simpl; try reflexivity.
    destruct (nth_error (a :: b :: t) i) eqn:Hn; simpl; [| reflexivity].
    assert (i < length (a :: b :: t)) by (apply nth_error_Some; congruence).
    rewrite remove_at_length by assumption. simpl in *. lia.
Qed.

(* Any run: no item is ever lost or duplicated. *)
Theorem items_preserved : forall A (d : A) rest events,
  size (fold_left reducer events (init d rest)) = 1 + length rest.
Proof.
  intros A d rest events.
  change (1 + length rest) with (size (init d rest)).
  generalize (init d rest) as s.
  induction events as [| e es IH]; intros s; simpl.
  - reflexivity.
  - rewrite IH. apply size_step.
Qed.

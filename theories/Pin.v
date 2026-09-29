(* The PIN and PUK logic of a SIM card, from workload W4 of encore-benchmarks
   (github.com/vbergeron/encore-benchmarks/tree/main/workloads/w4_pin),
   without its APDU driver. Three wrong PINs block the card, the PUK
   unblocks it, ten wrong PUKs and the card is dead. decks/rocq-solid.typ
   shows parts of this file. *)
From Stdlib Require Import Arith List Lia.
Import ListNotations.

Definition max_tries := 3.
Definition max_puk_tries := 10.

Record state := mk_state {
  pin : list nat;
  puk : list nat;
  tries : nat;       (* PIN attempts left *)
  puk_tries : nat;   (* PUK attempts left *)
  auth : bool        (* PIN verified in this session *)
}.

Inductive cmd :=
| Verify (guess : list nat)
| Change (new_pin : list nat)
| Unblock (puk_guess new_pin : list nat)
| Select
| Unknown.

Inductive resp :=
| Ok
| Wrong (left : nat)
| Blocked
| Denied
| BadIns.

Fixpoint digits_eqb (a b : list nat) : bool :=
  match a, b with
  | [], [] => true
  | x :: a', y :: b' => if x =? y then digits_eqb a' b' else false
  | _, _ => false
  end.

Definition step (s : state) (c : cmd) : state * resp :=
  match c with
  | Verify g =>
      match tries s with
      | O => (mk_state (pin s) (puk s) 0 (puk_tries s) false, Blocked)
      | S t =>
          if digits_eqb g (pin s)
          then (mk_state (pin s) (puk s) max_tries (puk_tries s) true, Ok)
          else (mk_state (pin s) (puk s) t (puk_tries s) false, Wrong t)
      end
  | Change p =>
      if auth s then (mk_state p (puk s) (tries s) (puk_tries s) true, Ok)
      else (s, Denied)
  | Unblock k p =>
      match puk_tries s with
      | O => (s, Blocked)
      | S t =>
          if digits_eqb k (puk s)
          then (mk_state p (puk s) max_tries max_puk_tries false, Ok)
          else (mk_state (pin s) (puk s) (tries s) t false, Wrong t)
      end
  | Select => (mk_state (pin s) (puk s) (tries s) (puk_tries s) false, Ok)
  | Unknown => (s, BadIns)
  end.

Lemma digits_eqb_eq : forall a b, digits_eqb a b = true <-> a = b.
Proof.
  induction a as [|x a IH]; intros [|y b]; cbn; split; intro H;
    try discriminate; try reflexivity.
  - destruct (Nat.eqb_spec x y); [|discriminate].
    apply IH in H. subst. reflexivity.
  - injection H as -> ->. rewrite Nat.eqb_refl. apply IH. reflexivity.
Qed.

(* The words of the theorem, one definition each. *)
Definition next_state (s : state) (c : cmd) : state :=
  fst (step s c).

Definition tries_go_up (s : state) (c : cmd) : Prop :=
  tries s < tries (next_state s c).

Definition right_pin (s : state) (c : cmd) : Prop :=
  c = Verify (pin s) /\ 0 < tries s.

Definition right_puk (s : state) (c : cmd) : Prop :=
  exists p, c = Unblock (puk s) p /\ 0 < puk_tries s.

(* No free retries: the PIN counter only goes back up on the right PIN
   while the card is not blocked, or the right PUK while the PUK is not
   blocked. *)
Theorem no_free_retries : forall (s : state) (c : cmd),
  tries_go_up s c -> right_pin s c \/ right_puk s c.
Proof.
  unfold tries_go_up, next_state, right_pin, right_puk.
  intros [pn pk t pt a] c; destruct c as [g|p|k p| |]; cbn in *;
    [ destruct t as [|t]; [|destruct (digits_eqb g pn) eqn:E]
    | destruct a
    | destruct pt as [|pt]; [|destruct (digits_eqb k pk) eqn:E]
    | | ]; cbn in *; intro H; try lia.
  - left. apply digits_eqb_eq in E. subst. split; [reflexivity | lia].
  - right. exists p. apply digits_eqb_eq in E. subst. split; [reflexivity | lia].
Qed.

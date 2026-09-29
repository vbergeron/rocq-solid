(* Example theory: decks/rocq-solid.typ includes this file verbatim, so the
   code on the slides is the code Rocq checks. *)
From Stdlib Require Import List.
Import ListNotations.

Fixpoint rev {A : Type} (l : list A) : list A :=
  match l with
  | [] => []
  | x :: xs => rev xs ++ [x]
  end.

Lemma rev_app {A : Type} (l1 l2 : list A) :
  rev (l1 ++ l2) = rev l2 ++ rev l1.
Proof.
  induction l1 as [| x xs IH]; simpl.
  - now rewrite app_nil_r.
  - now rewrite IH, app_assoc.
Qed.

Theorem rev_involutive : forall {A : Type} (l : list A), rev (rev l) = l.
Proof.
  intros A l.
  induction l as [| x xs IH]; simpl.
  - reflexivity.
  - now rewrite rev_app, IH.
Qed.

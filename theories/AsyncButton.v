(* The async button of Rocqducers (github.com/vbergeron/rocqducers): a
   button that tracks an in-flight request. decks/rocq-solid.typ shows
   this file verbatim. *)

Inductive state := Idle | Loading.

Inductive event := Click | Success | Failure.

Definition reducer (s : state) (e : event) : state :=
  match s, e with
  | Idle, Click => Loading
  | Loading, Success => Idle
  | Loading, Failure => Idle
  | _, _ => s
  end.

(* A second click while the request is in flight does nothing. *)
Theorem click_while_loading_is_ignored :
  reducer Loading Click = Loading.
Proof. reflexivity. Qed.

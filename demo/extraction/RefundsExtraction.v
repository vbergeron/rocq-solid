(* Extraction of the order handler of theories/Redelivery.v and the
   endless consumer of theories/Forever.v to Scala 3, with the
   rocq-extraction-scala plugin (github.com/vbergeron/rocq-extraction-scala).
   Needs Rocq >= 9.4; `dune build @extract` runs it and promotes
   Refunds.scala to scala/. *)
From Stdlib Require Import Arith.
(* bool, list and nat as Scala's Boolean, List and BigInt. *)
From ScalaExtraction Require Import ScalaExtraction ExtrScalaNatBigInt.
From Demo Require Import Redelivery Forever.

Extraction Language Scala.
Set Extraction Output Directory ".".
Set Extraction Scala Package "shop.refunds".
(* Pure arrows, [A -> B]: the extracted code has no side effects. *)
Set Extraction Scala Pure Functions.

(* Redelivery.v compares ids and amounts with Stdlib's [PeanoNat.Nat.eqb]
   and [PeanoNat.Nat.leb], copies of the Corelib functions that
   ExtrScalaNatBigInt maps: map them too. *)
Extract Constant PeanoNat.Nat.eqb => "a => b => a == b".
Extract Constant PeanoNat.Nat.leb => "a => b => a <= b".

Extraction "Refunds" handle replay states.

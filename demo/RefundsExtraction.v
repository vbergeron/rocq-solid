(* Extraction of the order handler of theories/Orders.v and the endless
   consumer of theories/Forever.v to Scala 3, with the rocq-extraction-scala
   plugin (github.com/vbergeron/rocq-extraction-scala). Needs Rocq >= 9.4;
   demo/extract.sh runs it and writes demo/scala/Refunds.scala. *)
From Stdlib Require Import Arith.
From ScalaExtraction Require Import ScalaExtraction.
From Solid Require Import Orders Forever.

Extraction Language Scala.
Set Extraction Output Directory ".".
Set Extraction Scala Package "shop.refunds".

(* Money as Scala's BigInt, not Peano numbers. *)
Extract Inductive nat => "BigInt" [ "BigInt(0)" "((n: BigInt) => n + 1)" ]
  "((fO: Any => Any) => (fS: Any => Any) => (n: BigInt) =>
      if (n == 0) fO(()) else fS(n - 1))".
Extract Constant Nat.add => "((n: BigInt) => (m: BigInt) => n + m)".
Extract Constant PeanoNat.Nat.eqb =>
  "((n: BigInt) => (m: BigInt) => if (n == m) True() else False())".
Extract Constant PeanoNat.Nat.leb =>
  "((n: BigInt) => (m: BigInt) => if (n <= m) True() else False())".

Extraction "Refunds" handle replay states.

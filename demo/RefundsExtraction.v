(* Extraction of the order handler of theories/Orders.v to Scala 3, with
   the rocq-extraction-scala plugin (github.com/vbergeron/rocq-extraction-scala).
   demo/extract.sh compiles theories/ and this file and writes Refunds.scala. *)
From ScalaExtraction Require Import ScalaExtraction.
From Solid Require Import Orders Redelivery.

Extraction Language Scala.
Set Extraction Scala Package "shop.refunds".

Extraction "Refunds" handle replay.

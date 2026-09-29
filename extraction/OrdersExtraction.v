(* Extraction of the order handler of theories/Orders.v to OCaml: dune
   writes orders.ml and compiles it as the [orders] library. *)
Set Warnings "-extraction-default-directory".
From Stdlib Require Import Extraction ExtrOcamlBasic ExtrOcamlNatInt.
From Solid Require Import Orders.

Extraction "orders.ml" handle replay.

(lang dune 3.21)
(using rocq 0.11)
(name rocq-solid)

(generate_opam_files true)

(source (github vbergeron/rocq-solid))
(license Apache-2.0)

(package
 (name rocq-solid)
 (synopsis "Rocq development accompanying the rocq-solid talk")
 (depends
  (dune (>= 3.21))
  (rocq-core (and (>= 9.1) (< 9.2)))
  (rocq-stdlib (and (>= 9.1) (< 9.2)))))

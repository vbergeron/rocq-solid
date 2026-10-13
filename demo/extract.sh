#!/usr/bin/env bash
# Extracts the order handler to demo/scala/Refunds.scala. Needs rocq >= 9.4
# (master) with rocq-extraction-scala on PATH: not the 9.1 of `mise run
# build`, see demo/README.md.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
cp "$root"/theories/{Orders,Forever}.v "$root"/demo/RefundsExtraction.v "$work"
cd "$work"
for f in Orders Forever RefundsExtraction; do rocq compile -Q . Solid "$f.v"; done
mv Refunds.scala "$root/demo/scala/Refunds.scala"
echo "wrote demo/scala/Refunds.scala"

#!/usr/bin/env bash

set -euo pipefail
OUTDIR=${1:?missing parameter outdir}

for f in "$OUTDIR"/*.rss; do
  if ! grep -q '<item>' "$f"; then
    echo "$f" does not have items, broken?
  fi
done
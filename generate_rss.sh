#!/usr/bin/env bash

set -euo pipefail

OUTDIR=${1:?missing parameter outdir}
mkdir -p "$OUTDIR"

curl -o mkfeed.py "https://raw.githubusercontent.com/dburic/mkfeed/master/mkfeed.py"
sha256sum -c <<<"96612dbe0c2c3a6b8b8a409846b621bf129aeb1d9b8155a7ca3ed3e755f0246b  mkfeed.py"
chmod +x mkfeed.py

clean_rss() {
    # remove constantly updated values
    file=$1
    sed -i 's/[0-9an]\+ \(hour\|day\|week\|month\)s\? ago//' "$file"
    sed -i 's/[0-9a-zA-Z]\{20,\}/hex-string/' "$file"
}

URL=https://archiveofourown.org/works/37432549
curl "$URL" -L | ./mkfeed.py \
    --pattern-item '<option {*}value="{%}"{*}>{%}</option>' \
    --feed-title 'Borne of Desire' \
    --feed-link "$URL" \
    --feed-desc "" \
    --item-title '{%2}' \
    --item-link "$URL/chapters/"'{%1}' \
    --item-desc "" \
    >"$OUTDIR"/pokemon-bod.rss

# look for the first title tag in each rss file
# then generate <li> for the index.html
GENERATED_LI_ENTRIES=$(cd "$OUTDIR"; find . -name '*.rss' -exec awk '
       /title>/ {printf "%s: %s\n", FILENAME, $0; exit}
       ' {} \; |
  sed 's_</\?title>__g;
       s_^_    <li><a href="_;
       s_:[ ]\+_">_;
       s_$_</a></li>_;')
export GENERATED_LI_ENTRIES
envsubst <index.html >"$OUTDIR"/index.html

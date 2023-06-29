#!/usr/bin/env bash

set -euo pipefail

OUTDIR=${1:?missing parameter outdir}
mkdir -p $OUTDIR

curl -o mkfeed.py "https://raw.githubusercontent.com/dburic/mkfeed/master/mkfeed.py"
sha256sum -c <<<"e043624cfa0005559d0a37d697af7c00fd7e9388cac70aa3329748b48e38ff0a  mkfeed.py"
chmod +x mkfeed.py
patch <mkfeed.py.patch

URL="https://www.backerkit.com/c/greater-than-games/spirit-island-nature-incarnate/community?filter=Crowdfunding%3A%3AProjectUpdate"
curl $URL | ./mkfeed.py \
    --pattern-item '<div id="body" {*}>{*}<a{*}href="{%}"{*}>{*}<p{*}>{%}</p>{*}</a>{*}<div class="trix-content">{%}</div>' \
    --feed-title 'Nature Incarnate' \
    --feed-link "$URL" \
    --feed-desc 'Spirit Island Nature Incarnate Updates' \
    --item-title '{%2}' \
    --item-link "$(cut -d/ -f1,2,3 <<<"$URL"){%1}" \
    --item-desc '{%3}' >"$OUTDIR"/nature-incarnate.rss

URL="https://tldrsec.com"
curl "$URL" | ./mkfeed.py \
    --pattern-main '<div class="col-span-12 w-full lg:col-span-9">{%}' \
    --pattern-item '<a{*}href="{%}"{*}>{*}<div{*}><h2 {*}>{%}</h2>{%}</div>' \
    --feed-title 'TL;DR Sec' \
    --feed-link "$URL" \
    --feed-desc 'TL;DR Sec does not have an rss feed anymore :(' \
    --item-title '{%2}' \
    --item-link "$(cut -d/ -f1,2,3 <<<"$URL"){%1}" \
    --item-desc '{%3}' >"$OUTDIR"/tldr.rss
sed -i 's/[0-9an]\+ \(hour\|day\)s\? ago//' "$OUTDIR"/tldr.rss # remove constantly updated value

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
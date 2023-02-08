#!/usr/bin/env bash

set -euo pipefail

URL="https://www.backerkit.com/c/greater-than-games/spirit-island-nature-incarnate/updates#top"

OUTDIR=${1:?missing parameter outdir}
mkdir -p $OUTDIR

curl -o mkfeed.py "https://raw.githubusercontent.com/dburic/mkfeed/master/mkfeed.py"
sha256sum -c <<<"e043624cfa0005559d0a37d697af7c00fd7e9388cac70aa3329748b48e38ff0a  mkfeed.py"
chmod +x mkfeed.py
patch <mkfeed.py.patch

exit 1
cp index.html $OUTDIR/index.html
curl $URL | ./mkfeed.py \
    --pattern-item '<div class="relative">{*}<a{*}href="{%}"{*}>{*}<div class="flex-auto ">{%}</div>' \
    --feed-title 'Nature Incarnate' \
    --feed-link "$URL" \
    --feed-desc 'Spirit Island Nature Incarnate Updates' \
    --item-title '{%2}' \
    --item-link "$(cut -d/ -f1,2,3 <<<$URL){%1}" \
    --item-desc '{%2}' >$OUTDIR/nature-incarnate.rss



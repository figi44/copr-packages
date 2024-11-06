#!/bin/bash

set -ex

ec=0

SPEC=yazi.spec
URL="https://api.github.com/repos/sxyazi/yazi/tags"

current_tag="$(rpmspec -q --qf "%{version}\n" $SPEC | head -1 | sed 's/\^.*//')"
latest_tag="$(curl $URL | jq -r '.[0].name' | sed 's/^v//')"

rpmdev-vercmp "$current_tag" "$latest_tag" || ec=$?
case $ec in
    0) ;;
    12) sed -i "/^Version:/s/$current_tag/$latest_tag/" $SPEC ;;
    *) exit 1
esac

git diff --quiet || { git commit -am "yazi: $current_tag -> $latest_tag" && git push; }
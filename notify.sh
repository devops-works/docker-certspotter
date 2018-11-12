#!/bin/bash

# shellcheck disable=SC1091
source /certspotter/utils.bash

MESSAGE="${1:-}"

if [ -n "${DNS_DOMAINS}" ]; then
  warn "New certificates found for ${DNS_DOMAINS}"
  export DNS_DOMAINS
  MESSAGE="New certificates found for ${DNS_DOMAINS}"
fi

for script in /certspotter/base-hooks.d/*; do
  $script "${MESSAGE}"
done

if [ -d /certspotter/hooks.d/ ]; then
  for script in /certspotter/hooks.d/*; do
    $script "${MESSAGE}"
  done
fi

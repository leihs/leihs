#!/usr/bin/env bash
set -e
set -u
BUNLDE_VERSION_DIGEST=`git hash-object 'Gemfile.lock'`
BUNDLE_CACHE_STAMP_FILE="/tmp/MADEK_BUNDLED_${BUNLDE_VERSION_DIGEST}_${RBENV_VERSION}"
if [ -e "$BUNDLE_CACHE_STAMP_FILE" ]; then
  echo "BUNDLE_CACHE_STAMP_FILE ${BUNDLE_CACHE_STAMP_FILE} exists, doing nothing"
else
  echo "bundling..."
  bundle
  echo "bundled $(date)" >> "$BUNDLE_CACHE_STAMP_FILE"
fi

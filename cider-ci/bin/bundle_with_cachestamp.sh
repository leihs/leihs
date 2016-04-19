#!/usr/bin/env bash
set -e
set -u
_RUBY_VERSION=$(cat .ruby-version)
BUNDLE_VERSION_DIGEST=`git hash-object 'Gemfile.lock'`
BUNDLE_CACHE_STAMP_FILE="/tmp/LEIHS_BUNDLED_${BUNDLE_VERSION_DIGEST}_${_RUBY_VERSION}"
if [ -e "$BUNDLE_CACHE_STAMP_FILE" ]; then
  echo "BUNDLE_CACHE_STAMP_FILE ${BUNDLE_CACHE_STAMP_FILE} exists, doing nothing"
else
  echo "bundling..."
  bundle
  echo "bundled $(date)" >> "$BUNDLE_CACHE_STAMP_FILE"
  rbenv rehash
fi

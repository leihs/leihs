#!/usr/bin/env bash
set -eux

DIGEST=`git ls-tree HEAD -- cider-ci config engines/procurement/app/assets engines/leihs_admin/app/assets app/assets Gemfile.lock | openssl dgst -sha1 | cut -d ' ' -f 2`

ASSETS_CACHE_DIR="/tmp/assets_${DIGEST}"
if [ -d "$ASSETS_CACHE_DIR" ]; then
  echo "assets cache exists, just copying ..."
else
  bundle exec rake assets:precompile
  mv public/assets "${ASSETS_CACHE_DIR}"
fi
cp -r "$ASSETS_CACHE_DIR" public/assets

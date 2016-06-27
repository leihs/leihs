#!/usr/bin/env bash
set -eux

export PATH=~/.rubies/$RUBY/bin:$PATH

DIGEST=`git ls-tree HEAD -- \
  cider-ci_v4 \
  config app/assets Gemfile Gemfile.lock \
  engines/**/config engines/**/app/assets engines/**/Gemfile engines/**/Gemfile.lock engines/**/*.gemspec \
  | openssl dgst -sha1 \
  | cut -d ' ' -f 2`

ASSETS_CACHE_DIR="/tmp/assets_${DIGEST}"
if [ -d "$ASSETS_CACHE_DIR" ]; then
  echo "assets cache exists, just linking..."
else
  bundle exec rake assets:precompile
  mv public/assets "${ASSETS_CACHE_DIR}"
  # the logo file name is stored in DB and we need it un-precompiled
  cp app/assets/images/image-logo-zhdk.png "${ASSETS_CACHE_DIR}"
  # for this specific library we also need it un-precompiled
  cp -r vendor/assets/javascripts/simile_timeline/* "${ASSETS_CACHE_DIR}/simile_timeline/"
fi
ln -s "$ASSETS_CACHE_DIR" public/assets

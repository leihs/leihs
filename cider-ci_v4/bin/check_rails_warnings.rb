#!/usr/bin/env bash
set -eu

export PATH=~/.rubies/$RUBY/bin:$PATH

RAILS_ENV=test bundle exec rails runner ''

if [ $(RAILS_ENV=test bundle exec rails runner '' 2>&1 | wc -l) -gt 0 ]; then
  exit 1;
else
  exit 0;
fi

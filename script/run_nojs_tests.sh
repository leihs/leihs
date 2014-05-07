#!/bin/bash

bash script/validate_gettext_files.sh

bundle exec rake leihs:reset
bundle exec rake app:test:generate_personas_dumps
bundle exec rspec spec/
bundle exec cucumber -t ~@javascript features/

if [ -f tmp/rerun.txt ]; then
  bundle exec cucumber -t ~@javascript -p rerun
fi

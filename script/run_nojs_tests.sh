#!/bin/bash

bash script/validate_gettext_files.sh && \
bundle exec rake leihs:reset && \
bundle exec cucumber -t ~@javascript features/


if [[ $? -ne 0 ]]; then
  if [[ -f tmp/rerun.txt && -s tmp/rerun.txt ]]; then
    echo "Rerun necessary, the first execution exited with non-0."
    bundle exec cucumber -t ~@javascript -p rerun
    exit $?
  else
    echo "Something went wrong during test setup or execution before even running Cucumber."
    exit 1
  fi
fi

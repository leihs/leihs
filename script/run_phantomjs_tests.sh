#!/bin/bash

bash script/validate_gettext_files.sh && \
bundle exec rake leihs:reset && \
bundle exec cucumber -t @javascript -t ~@firefox features/

if [[ -f tmp/rerun.txt && -s tmp/rerun.txt && $? -ne 0 ]]; then
  echo "Rerun necessary, the first execution exited with non-0."
  bundle exec cucumber -t @javascript -t ~@firefox -p rerun
fi

exit $?

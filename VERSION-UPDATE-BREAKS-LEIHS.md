+ ./bin/git-check-submodule-consistency
No preset version installed for command ruby
Please install a version by running one of the following:

asdf install ruby 3.3.8

or add one of the following versions in your config file at /tmp/ci_working-dir/b5d5fa8a-2922-4a16-becf-07e71cf9a989/.tool-versions
ruby 3.1.3
ruby 3.3.7
ruby 3.2.4

---

+ ./bin/git-check-ahead-of-origin-master
No preset version installed for command ruby
Please install a version by running one of the following:

asdf install ruby 3.3.8

or add one of the following versions in your config file at /tmp/ci_working-dir/75f8f554-3e18-4219-aa75-a3f90c5d3731/.tool-versions
ruby 3.1.3
ruby 3.3.7
ruby 3.2.4

--


#!/usr/bin/env bash
set -euo pipefail
cd $LEIHS_INTEGRATION_TESTS_DIR
./bin/env/ruby-setup
   Stderr
No preset version installed for command bundle
Please install a version by running one of the following:

asdf install ruby 3.3.8

or add one of the following versions in your config file at /tmp/ci_working-dir/d96711d7-0018-499b-a2e9-6e32204ce432/integration-tests/.tool-versions
ruby 3.1.3
ruby 3.3.7
ruby 3.2.4
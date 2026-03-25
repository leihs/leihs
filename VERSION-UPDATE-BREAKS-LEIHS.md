# Ruby 3.3.8 bump — CI / asdf failures

## What broke

After setting `ruby 3.3.8` in `.tool-versions`, cider-ci jobs failed because executors only had older Rubies preinstalled (e.g. 3.1.3, 3.3.7, 3.2.4). asdf reported *No preset version installed* when invoking `ruby` or `bundle` before 3.3.8 was installed.

Example symptoms:

- `./bin/git-check-submodule-consistency` — fails on `ruby` (script calls `ruby` with no prior setup).
- `./bin/git-check-ahead-of-origin-master` — same.
- `integration-tests`: `./bin/env/ruby-setup` then `bundle install` — fails if Ruby 3.3.8 is not available / install did not complete.

## Root cause

**Meta** tasks (`submodule-consistency`, `ahead-of-master`) ran the git-check wrappers **without** running `./bin/env/ruby-setup`, unlike other task components that bundle or lint Ruby. So asdf never installed the version requested in `.tool-versions` before those scripts ran.

## Fix (in this repo)

In:

- `cider-ci/task-components/submodule-consistency.yml`
- `cider-ci/task-components/ahead-of-master.yml`

after `git submodule update --init --recursive --force`, add:

1. `./bin/env/ruby-setup` — installs the Ruby version from `.tool-versions` via asdf (or mise).
2. `exclusive_executor_resource: asdf-ruby` on the `test` script — same serialization as other asdf Ruby installs.

Then the existing `./bin/git-check-*` calls run with the correct Ruby.

## If integration-tests still fail

Those jobs already use `integration-tests/cider-ci/task-components/ruby-bundle.yml`, which runs `./bin/env/ruby-setup`. If errors persist, inspect the full log for `asdf install ruby` / `ruby-build` (network, build dependencies, timeouts). Fallbacks: pin to a preinstalled patch level (e.g. 3.3.7) or update the cider-ci executor image to include 3.3.8.

## Historical log (raw CI excerpts)

<details>
<summary>Original stderr snippets</summary>

```
+ ./bin/git-check-submodule-consistency
No preset version installed for command ruby
...
asdf install ruby 3.3.8
...
+ ./bin/git-check-ahead-of-origin-master
No preset version installed for command ruby
...
cd $LEIHS_INTEGRATION_TESTS_DIR
./bin/env/ruby-setup
No preset version installed for command bundle
...
```

</details>

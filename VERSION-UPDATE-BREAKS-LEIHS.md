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

Those jobs already use `integration-tests/cider-ci/task-components/ruby-bundle.yml`, which runs `./bin/env/ruby-setup`.

### asdf vs mise (bundle shim)

If the executor has **both** `mise` and `asdf` on `PATH`, the old `select-tool-versions-manager` picked **mise** first. `./bin/env/ruby-setup` then installed Ruby with mise, but `bundle` often resolved to **asdf’s shim**, which had no matching Ruby → *No preset version installed for command bundle*. **Fix:** prefer **asdf** when it is available (see `bin/env/select-tool-versions-manager` copies), matching cider-ci `traits: asdf: true`. Local mise-only setups still work when asdf is absent; to force mise with both installed, set `TOOL_VERSIONS_MANAGER=mise`.

### Other causes

If errors persist after that, inspect the full log for `asdf install ruby` / `ruby-build` (network, build dependencies, timeouts). Fallbacks: pin to a preinstalled patch level (e.g. 3.3.7) or update the cider-ci executor image to include 3.3.8.

### ruby-build `Killed` (OOM)

If the log shows **`Killed`** during `asdf install` / ruby-build (`BUILD FAILED (Debian … using ruby-build …)`), the Linux OOM killer likely stopped the compile. **`asdf-apply-ruby-low-memory-build-opts`** in each `bin/env/asdf-helper.bash` enables **CI-only** lower-memory settings when `CIDER_CI_WORKING_DIR`, `CI=true`, `CIDER_CI_TRIAL_ID`, or a path under `ci_working-dir` is detected: **`RUBY_MAKE_OPTS=-j 1`** and **`RUBY_CONFIGURE_OPTS` … `--disable-install-doc`**. If builds still die, increase executor memory or use a Ruby version already preinstalled on the image.

### Stale or broken asdf Ruby

The per-tree cache in `asdf-update-plugin` can skip `asdf install` while the install directory is missing or corrupt. **`asdf-verify-ruby-install`** in each `bin/env/asdf-helper.bash` runs at the end of `asdf-update-plugin` when `ASDF_PLUGIN=ruby`: `asdf reshim`, then `asdf exec ruby -e 'print RUBY_VERSION'` must match the `ruby` line in that project’s `.tool-versions`; otherwise it logs a warning, `asdf uninstall` / `asdf install`, reshims again, and fails hard if still broken.

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

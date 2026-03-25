function asdf-load() {
  if type "asdf" > /dev/null; then
    echo "asdf OK"
  else
    echo "sourcing asdf from ~/.asdf/asdf.sh since it seems not present"
    source ~/.asdf/asdf.sh
  fi
}

# True when running in cider-ci / generic CI (same idea as low-memory opts).
function asdf-ci-like-env() {
  [[ -n "${CIDER_CI_WORKING_DIR:-}" || "${CI:-}" == "true" ||
     -n "${CIDER_CI_TRIAL_ID:-}" || "${PWD:-}" == *ci_working-dir* ]]
}

# cider-ci / generic CI: compiling Ruby can OOM; use single-job make and skip docs.
function asdf-apply-ruby-low-memory-build-opts() {
  [[ "${ASDF_PLUGIN:-}" == "ruby" ]] || return 0
  if [[ -z "${CIDER_CI_WORKING_DIR:-}" && "${CI:-}" != "true" &&
        -z "${CIDER_CI_TRIAL_ID:-}" && "${PWD:-}" != *ci_working-dir* ]]; then
    return 0
  fi
  echo "INFO CI: low-memory ruby-build (RUBY_MAKE_OPTS=-j 1, --disable-install-doc)"
  export RUBY_MAKE_OPTS="${RUBY_MAKE_OPTS:--j 1}"
  if [[ "${RUBY_CONFIGURE_OPTS:-}" != *--disable-install-doc* ]]; then
    export RUBY_CONFIGURE_OPTS="${RUBY_CONFIGURE_OPTS:+${RUBY_CONFIGURE_OPTS} }--disable-install-doc"
  fi
}

# CI: if an MRI with the same major.minor is already under ~/.asdf/installs/ruby, use that patch (no compile).
function asdf-resolve-ruby-install-version() {
  asdf-load
  [[ -f "$PROJECT_DIR/.tool-versions" ]] || return 0
  local desired
  desired=$(grep -E '^ruby[[:space:]]' "$PROJECT_DIR/.tool-versions" | head -1 | awk '{print $2}')
  [[ -n "$desired" ]] || return 0
  export LEIHS_RUBY_PATCH_FALLBACK=0
  export ASDF_RUBY_INSTALL_VERSION="$desired"

  if ! asdf-ci-like-env; then
    return 0
  fi

  local install_root="${ASDF_DIR:-$HOME/.asdf}/installs/ruby"
  [[ -d "$install_root" ]] || return 0

  local want_mm candidates="" v chosen
  want_mm=$(echo "$desired" | cut -d. -f1,2)
  shopt -s nullglob
  for v in "$install_root"/*; do
    [[ -d "$v" ]] || continue
    v=$(basename "$v")
    [[ "$v" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || continue
    [[ "$(echo "$v" | cut -d. -f1,2)" == "$want_mm" ]] || continue
    candidates+="${v}"$'\n'
  done
  shopt -u nullglob
  [[ -z "$candidates" ]] && return 0

  chosen=$(printf '%s' "$candidates" | sort -V | tail -1)
  [[ -z "$chosen" ]] && return 0

  export ASDF_RUBY_INSTALL_VERSION="$chosen"
  if [[ "$chosen" != "$desired" ]]; then
    export LEIHS_RUBY_PATCH_FALLBACK=1
    echo "INFO CI: using installed Ruby ${chosen} (same major.minor as .tool-versions ${desired}; avoid compiling ${desired})"
  fi
}

function asdf-ruby-version-ok() {
  local actual="$1" expected="$2"
  [[ -n "$actual" ]] || return 1
  if [[ "${LEIHS_RUBY_PATCH_FALLBACK:-0}" == "1" ]]; then
    [[ "$(echo "$actual" | cut -d. -f1,2)" == "$(echo "$expected" | cut -d. -f1,2)" ]]
  else
    [[ "$actual" == "$expected" ]]
  fi
}

# Ensure MRI in .tool-versions runs; reinstall if missing, broken, or stale (e.g. cache skip + bad tree).
function asdf-verify-ruby-install() {
  asdf-load
  local proj_dir
  proj_dir="$(cd -- "$(dirname "${BASH_SOURCE}")" ; cd ../.. > /dev/null 2>&1 && pwd -P)"
  [[ -f "$proj_dir/.tool-versions" ]] || return 0
  local expected
  expected=$(grep -E '^ruby[[:space:]]' "$proj_dir/.tool-versions" | head -1 | awk '{print $2}')
  [[ -n "$expected" ]] || return 0

  local install_ver="${ASDF_RUBY_INSTALL_VERSION:-$expected}"

  cd "$proj_dir"
  asdf reshim ruby 2>/dev/null || true

  local actual
  actual=$(asdf exec ruby -e 'print RUBY_VERSION' 2>/dev/null) || actual=""
  if asdf-ruby-version-ok "$actual" "$expected"; then
    return 0
  fi

  echo "WARNING asdf ruby missing, broken, or stale (expected ${expected}, got ${actual:-<failed>}); reinstalling"
  asdf-apply-ruby-low-memory-build-opts
  asdf uninstall ruby "$install_ver" 2>/dev/null || true
  asdf install ruby "$install_ver"
  asdf reshim ruby

  actual=$(asdf exec ruby -e 'print RUBY_VERSION' 2>/dev/null) || actual=""
  if ! asdf-ruby-version-ok "$actual" "$expected"; then
    echo "ERROR asdf ruby still broken after reinstall (expected ${expected}, got ${actual:-<failed>})" >&2
    return 1
  fi
}

function asdf-update-plugin-base(){
  echo "INFO updateting asdf plugin ${ASDF_PLUGIN} for ${PROJECT_NAME}"
  asdf-load
  if $(asdf plugin list | grep -q $ASDF_PLUGIN); then
    echo "asdf $ASDF_PLUGIN found: updating "
    asdf plugin update $ASDF_PLUGIN
  else
    echo "asdf $ASDF_PLUGIN NOT found: installing "
    asdf plugin add $ASDF_PLUGIN ${ASDF_PLUGIN_URL}
  fi
  cd $PROJECT_DIR
  asdf-apply-ruby-low-memory-build-opts
  if [[ "${ASDF_PLUGIN:-}" == "ruby" ]]; then
    asdf install ruby "${ASDF_RUBY_INSTALL_VERSION}"
  else
    asdf install $ASDF_PLUGIN
  fi
}

function asdf-update-plugin () {
  asdf-load
  TMPDIR=${TMPDIR:-/tmp/}
  PROJECT_DIR="$(cd -- "$(dirname "${BASH_SOURCE}")" ; cd ../.. > /dev/null 2>&1 && pwd -P)"
  if [[ "${ASDF_PLUGIN:-}" == "ruby" ]]; then
    asdf-resolve-ruby-install-version
  fi
  # in deployed states we are not in a git repo; however asdf und plugins should be set up already
  if ! git -C $PROJECT_DIR rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "WARNING ${PROJECT_DIR} is not a git repository, SKIPPING asdf plugin and install update"
  else
    if [[ $(git -C $PROJECT_DIR status -s) ]]; then
      echo "WARNING ${PROJECT_DIR} has uncommitted changes, forcing asdf plugin and install update"
      asdf-update-plugin-base
    else
      DIGEST=$(git log -1 HEAD --pretty=format:%T)
      CACHE_FILE="${TMPDIR}asdf_cache_${PROJECT_NAME}_${ASDF_PLUGIN}_${DIGEST}"
      if [[ -f $CACHE_FILE ]]; then
        echo "INFO $CACHE_FILE exists; skipping ${PROJECT_NAME} asdf update"
      else
        asdf-update-plugin-base
        touch $CACHE_FILE
      fi
    fi
  fi
  if [[ "${ASDF_PLUGIN:-}" == "ruby" ]]; then
    asdf-verify-ruby-install
  fi
}

# vim: set ft=sh

function asdf-load() {
  if type "asdf" > /dev/null; then
    echo "asdf OK"
  else
    echo "sourcing asdf from ~/.asdf/asdf.sh since it seems not present"
    source ~/.asdf/asdf.sh
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
  asdf install $ASDF_PLUGIN
}

function asdf-update-plugin () {
  asdf-load
  TMPDIR=${TMPDIR:-/tmp/}
  PROJECT_DIR="$(cd -- "$(dirname "${BASH_SOURCE}")" ; cd ../.. > /dev/null 2>&1 && pwd -P)"
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
}

# vim: set ft=sh

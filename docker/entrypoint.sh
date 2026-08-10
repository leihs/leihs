#!/usr/bin/env bash
#
# leihs-docker entrypoint (PID 1)
#
# Flow (mirrors the Ansible deployment leihs/leihs_deploy, install_play.yml):
#   1. Set defaults/env variables (defaults.yml)
#   2. Create/persist the master secret
#   3. Render configuration (config.env, database.yml, puma.rb, Apache)
#   4. Initialize PostgreSQL (cluster, role root, DB leihs, structure+seeds)
#   5. Run migrations (leihs-migration.service)
#   6. Start services (supervisor, like systemd Restart=always)
#
set -euo pipefail

export LEIHS_ROOT_DIR="${LEIHS_ROOT_DIR:-/leihs}"

# --- Defaults (mirror of leihs_deploy/defaults.yml) -----------------------------
export LEIHS_EXTERNAL_HOSTNAME="${LEIHS_EXTERNAL_HOSTNAME:-leihs.example.org}"
export LEIHS_SEND_MAILS="${LEIHS_SEND_MAILS:-No}"
export LEIHS_CRON_TIME="${LEIHS_CRON_TIME:-04:00}"
export LEIHS_CRON_RANDOMIZED_DELAY_MAX_SECONDS="${LEIHS_CRON_RANDOMIZED_DELAY_MAX_SECONDS:-3600}"

export DB_HOST="${DB_HOST:-localhost}"
export DB_PORT="${DB_PORT:-5415}"
export DB_NAME="${DB_NAME:-leihs}"
export DB_USER="${DB_USER:-root}"
export DB_PASSWORD="${DB_PASSWORD:-root}"

export ENABLE_AUTH_HEADER_PREFIX_BASIC="${ENABLE_AUTH_HEADER_PREFIX_BASIC:-true}"
export PUBLISH_INVENTORY="${PUBLISH_INVENTORY:-false}"
export WEBSTATS_ENABLED="${WEBSTATS_ENABLED:-true}"
export RESTRICT_ACCESS_VIA_BASIC_AUTH="${RESTRICT_ACCESS_VIA_BASIC_AUTH:-false}"
export RESTRICT_ACCESS_VIA_BASIC_AUTH_PASSWORDS="${RESTRICT_ACCESS_VIA_BASIC_AUTH_PASSWORDS:-}"

export LEIHS_PUMA_WORKERS="${LEIHS_PUMA_WORKERS:-2}"
export LEIHS_PUMA_THREADS="${LEIHS_PUMA_THREADS:-5}"

# HTTP ports (Ansible defaults; configurable per service)
export LEIHS_LEGACY_HTTP_PORT="${LEIHS_LEGACY_HTTP_PORT:-3210}"
export LEIHS_ADMIN_HTTP_PORT="${LEIHS_ADMIN_HTTP_PORT:-3220}"
export LEIHS_PROCURE_HTTP_PORT="${LEIHS_PROCURE_HTTP_PORT:-3230}"
export LEIHS_PROCURE_CLIENT_HTTP_PORT="${LEIHS_PROCURE_CLIENT_HTTP_PORT:-3231}"
export LEIHS_MY_HTTP_PORT="${LEIHS_MY_HTTP_PORT:-3240}"
export LEIHS_BORROW_HTTP_PORT="${LEIHS_BORROW_HTTP_PORT:-3250}"
export LEIHS_INVENTORY_HTTP_PORT="${LEIHS_INVENTORY_HTTP_PORT:-3260}"

# Java heap per service (Ansible defaults)
export LEIHS_JAVA_XMX_ADMIN="${LEIHS_JAVA_XMX_ADMIN:-1G}"
export LEIHS_JAVA_XMX_BORROW="${LEIHS_JAVA_XMX_BORROW:-1G}"
export LEIHS_JAVA_XMX_PROCURE="${LEIHS_JAVA_XMX_PROCURE:-1G}"
export LEIHS_JAVA_XMX_MY="${LEIHS_JAVA_XMX_MY:-500m}"
export LEIHS_JAVA_XMX_MAIL="${LEIHS_JAVA_XMX_MAIL:-500m}"
export LEIHS_JAVA_XMX_INVENTORY="${LEIHS_JAVA_XMX_INVENTORY:-1G}"
export LEIHS_DB_MAX_POOL_SIZE="${LEIHS_DB_MAX_POOL_SIZE:-20}"

# --- Master secret ----------------------------------------------------------------
# From env or persisted in /leihs/var/master_secret (like inventory/master_secret.txt)
if [ -z "${LEIHS_MASTER_SECRET:-}" ]; then
  mkdir -p "${LEIHS_ROOT_DIR}/var"
  SECRET_FILE="${LEIHS_ROOT_DIR}/var/master_secret"
  if [ ! -s "${SECRET_FILE}" ]; then
    tr -dc 'A-Za-z0-9' </dev/urandom | head -c 40 > "${SECRET_FILE}"
    chmod 600 "${SECRET_FILE}"
  fi
  export LEIHS_MASTER_SECRET="$(cat "${SECRET_FILE}")"
fi

# --- LEIHS_VERSION (build arg or unknown) ------------------------------------------
export LEIHS_VERSION="${LEIHS_VERSION:-${LEIHS_VERSION_BUILD:-unknown}}"

echo "[leihs] version=${LEIHS_VERSION} ref=${LEIHS_VERSION_BUILD:-?} hostname=${LEIHS_EXTERNAL_HOSTNAME}"

# --- Render configuration -------------------------------------------------------------
/usr/local/lib/leihs/render-config.sh

# --- Initialize database + migrate ------------------------------------------------------
/usr/local/lib/leihs/init-db.sh

# --- Start services (supervisor, stays PID 1) ---------------------------------------------
exec /usr/local/lib/leihs/start-services.sh

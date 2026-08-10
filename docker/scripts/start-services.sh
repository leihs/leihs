#!/usr/bin/env bash
#
# start-services.sh — supervisor for all leihs services.
#
# Replicates the systemd units from leihs_deploy:
#   leihs-migration.service (already ran in init-db.sh, RemainAfterExit)
#   leihs-admin/borrow/procure/my/mail/inventory.service (Restart=always)
#   leihs-legacy.service          (puma, Restart=always)
#   leihs-legacy-cron.timer       (rake leihs:cron, daily)
#   apache2 (reverse-proxy-leihs)
#
# Behavior: every service runs in a restart loop (like systemd
# Restart=always). On SIGTERM/SIGINT all children are shut down cleanly.
#
set -uo pipefail

log() { echo "[leihs:svc] $(date -Is) $*"; }

# --- global service environment ---------------------------------------------------
set -a
# shellcheck disable=SC1091
source /etc/leihs/config.env
set +a
export JAVA_HOME=/opt/java
export PATH="/opt/ruby/bin:/opt/java/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# --- restart loop (equivalent to systemd Restart=always) ----------------------------
# "$@" is executed in the same shell process (run_* use `exec`), so the process
# can be observed directly.
supervise() {
  local name="$1"; shift
  local pid rc
  while :; do
    "$@" >> "/var/log/leihs/${name}.log" 2>&1 &
    pid=$!
    log "${name} started (pid ${pid})"
    wait "${pid}" 2>/dev/null
    rc=$?
    if [ -f /tmp/leihs-shutdown ]; then
      log "${name} stopped (rc=${rc}) — shutdown"
      return 0
    fi
    log "${name} exited (rc=${rc}) — restart in 5s"
    sleep 5
  done
}

# --- Services ------------------------------------------------------------------------

# Apache2 reverse proxy (vhosts were enabled in render-config.sh)
supervise apache2 apache2ctl -DFOREGROUND &
SUPERVISORS+=("$!")

# Tail Apache logs to stdout (container visibility; -F waits for file appearance)
( tail -n +1 -F "/var/log/apache2/leihs_${LEIHS_EXTERNAL_HOSTNAME}_error.log" \
          "/var/log/apache2/leihs_${LEIHS_EXTERNAL_HOSTNAME}_access.log" \
    2>/dev/null >> "/var/log/leihs/apache2-logs.stdout" ) &
SUPERVISORS+=("$!")

# leihs-legacy (Puma, Rails) — leihs-legacy.service
run_legacy() {
  cd "${LEIHS_ROOT_DIR}/legacy" || exit 1
  export LEIHS_SECRET="${LEIHS_MASTER_SECRET}"
  export SECRET_KEY_BASE="${LEIHS_MASTER_SECRET}"
  export RAILS_LOG_LEVEL=WARN
  export RAILS_ENV=production
  export RAILS_SERVE_STATIC_FILES=Yes
  export LEIHS_SHOW_NEW_INVENTORY_BUTTON=$([ "${PUBLISH_INVENTORY:-false}" = "true" ] && echo true || echo false)
  exec bundle exec puma -C config/puma.rb
}
supervise legacy run_legacy &
SUPERVISORS+=("$!")

# Java services (fat jars) — leihs-*.service
run_jar() {
  local name="$1" xmx="$2" pool="$3" port="$4"
  cd "${LEIHS_ROOT_DIR}/${name}" || exit 1
  export HTTP_PORT="${port}"
  export DB_MAX_POOL_SIZE="${pool}"
  exec java "-Xmx${xmx}" -jar "leihs-${name}.jar" run
}

supervise admin   run_jar admin   "${LEIHS_JAVA_XMX_ADMIN}"    "${LEIHS_DB_MAX_POOL_SIZE}" "${LEIHS_ADMIN_HTTP_PORT}" &
SUPERVISORS+=("$!")
supervise borrow  run_jar borrow  "${LEIHS_JAVA_XMX_BORROW}"   "${LEIHS_DB_MAX_POOL_SIZE}" "${LEIHS_BORROW_HTTP_PORT}" &
SUPERVISORS+=("$!")
supervise procure run_jar procure "${LEIHS_JAVA_XMX_PROCURE}"  "${LEIHS_DB_MAX_POOL_SIZE}" "${LEIHS_PROCURE_HTTP_PORT}" &
SUPERVISORS+=("$!")
supervise my      run_jar my      "${LEIHS_JAVA_XMX_MY}"       10                          "${LEIHS_MY_HTTP_PORT}" &
SUPERVISORS+=("$!")
supervise mail    run_jar mail    "${LEIHS_JAVA_XMX_MAIL}"     10                          "" &
SUPERVISORS+=("$!")

# leihs-inventory only when PUBLISH_INVENTORY=true (start-services.yml)
if [ "${PUBLISH_INVENTORY:-false}" = "true" ]; then
  supervise inventory run_jar inventory "${LEIHS_JAVA_XMX_INVENTORY}" "${LEIHS_DB_MAX_POOL_SIZE}" "${LEIHS_INVENTORY_HTTP_PORT}" &
  SUPERVISORS+=("$!")
  log "inventory service enabled (PUBLISH_INVENTORY=true)"
else
  log "inventory service disabled (PUBLISH_INVENTORY != true)"
fi

# --- cron loop (leihs-legacy-cron.timer, daily) ------------------------------------------
cron_loop() {
  local now next delay
  while :; do
    now=$(date +%s)
    next=$(date -d "today ${LEIHS_CRON_TIME}" +%s 2>/dev/null) || next=0
    if [ "${next}" -le "${now}" ]; then
      next=$(date -d "tomorrow ${LEIHS_CRON_TIME}" +%s)
    fi
    delay=$(( RANDOM % LEIHS_CRON_RANDOMIZED_DELAY_MAX_SECONDS ))
    log "cron: next run at $(date -d "@$(( next + delay ))" '+%Y-%m-%d %H:%M:%S')"
    sleep "$(( next - now + delay ))"
    [ -f /tmp/leihs-shutdown ] && return 0
    log "cron: rake leihs:cron"
    (
      cd "${LEIHS_ROOT_DIR}/legacy" || exit 1
      export LEIHS_SECRET="${LEIHS_MASTER_SECRET}"
      export SECRET_KEY_BASE="${LEIHS_MASTER_SECRET}"
      export RAILS_LOG_LEVEL=WARN
      export RAILS_ENV=production
      export PATH="/opt/ruby/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
      bundle exec rake leihs:cron
    ) >> "/var/log/leihs/cron.log" 2>&1
  done
}
supervise cron cron_loop &
SUPERVISORS+=("$!")

# --- signal handling ----------------------------------------------------------------------
shutdown() {
  log "SIGTERM received — stopping all services"
  touch /tmp/leihs-shutdown
  apache2ctl stop >/dev/null 2>&1 || true
  pkill -TERM -x java 2>/dev/null || true          # leihs-*.jar
  pkill -TERM -f 'puma' 2>/dev/null || true        # leihs-legacy
  pkill -TERM -x sleep 2>/dev/null || true         # cron/restart loops
  sleep 3
  pkill -KILL -x java 2>/dev/null || true
  pkill -KILL -f 'puma' 2>/dev/null || true
  pkill -TERM -f 'tail -n +1 -F' 2>/dev/null || true
  log "all services stopped"
}
trap shutdown TERM INT

log "all services started. container ready."
wait
exit 0

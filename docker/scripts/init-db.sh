#!/usr/bin/env bash
#
# init-db.sh — database bootstrap: role, DB leihs, structure/seeds, migrations.
#
# All client logic runs over TCP against ${DB_HOST}:${DB_PORT} — a single code
# path, regardless of whether PostgreSQL runs in the same container
# (DB_HOST=localhost, single-container mode) or as a separate container
# (compose split, DB_HOST=<service name>).
#
# The local cluster is only ensured when DB_HOST points to localhost
# (server side only: create/start the cluster). All client steps (role,
# databases, structure/seeds, migrations) go over TCP.
#
# Corresponds to the Ansible steps:
#   roles/postgresql             (pgdg PG15, port 5415)
#   roles/leihs-database-install (role root, DB leihs, structure.sql + seeds.sql)
#   leihs-migration.service      (bundle exec rake db:migrate)
#
# Idempotent: runs on every container start; existing data is preserved.
#
set -euo pipefail

log() { echo "[leihs:db] $*" >&2; }

# --- 0. Single-container mode only: ensure the local cluster ------------------------
case "${DB_HOST}" in
  localhost|127.0.0.1|::1)
    PGVERSION=$(ls /usr/lib/postgresql/ | sort -V | tail -1)
    export PGVERSION
    PGBIN="/usr/lib/postgresql/${PGVERSION}/bin"
    PGDATA="/var/lib/postgresql/${PGVERSION}/main"
    export PGDATA

    if [ ! -x "${PGBIN}/postgres" ]; then
      echo "[leihs:db] ERROR: PostgreSQL binaries not found under ${PGBIN}" >&2
      exit 1
    fi

    if [ ! -s "${PGDATA}/PG_VERSION" ]; then
      log "no cluster at ${PGDATA} — creating a new cluster"
      mkdir -p /var/lib/postgresql
      pg_createcluster "${PGVERSION}" main --start >/dev/null 2>&1 || \
        ( su postgres -c "${PGBIN}/initdb -D ${PGDATA} -E UTF8 --locale=C.UTF-8" >/dev/null 2>&1 \
          && log "cluster created via initdb" )
    fi

    PGCONF="/etc/postgresql/${PGVERSION}/main/postgresql.conf"
    if ! grep -qE "^port = ${DB_PORT}$" "${PGCONF}"; then
      sed -i "s/^#\?port = .*/port = ${DB_PORT}/" "${PGCONF}"
      log "port ${DB_PORT} set in ${PGCONF}"
    fi

    if ! pg_isready -q -h localhost -p "${DB_PORT}" 2>/dev/null; then
      pg_ctlcluster "${PGVERSION}" main start || pg_ctlcluster "${PGVERSION}" main restart
    fi

    # Create the initial superuser ${DB_USER} — local first-bootstrap only, via
    # the postgres OS user (peer auth on the unix socket). In split mode the
    # postgres image does this (POSTGRES_USER). Everything after this is TCP.
    su postgres -c "psql -p ${DB_PORT} -v ON_ERROR_STOP=1 -q" <<SQL
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '${DB_USER}') THEN
    CREATE ROLE ${DB_USER} SUPERUSER CREATEDB LOGIN PASSWORD '${DB_PASSWORD}';
  ELSE
    ALTER ROLE ${DB_USER} WITH SUPERUSER CREATEDB LOGIN PASSWORD '${DB_PASSWORD}';
  END IF;
END
\$\$;
SQL
    ;;
esac

# --- 1. Wait for the database (always TCP) ---------------------------------------------
for _ in $(seq 1 60); do
  pg_isready -q -h "${DB_HOST}" -p "${DB_PORT}" && break
  sleep 1
done
pg_isready -q -h "${DB_HOST}" -p "${DB_PORT}" \
  || { echo "[leihs:db] PostgreSQL ${DB_HOST}:${DB_PORT} not reachable" >&2; exit 1; }
log "PostgreSQL reachable: ${DB_HOST}:${DB_PORT}"

export PGPASSWORD="${DB_PASSWORD}"
PSQL=(psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -v ON_ERROR_STOP=1 -q)

# --- 2. Ensure role ${DB_USER} (idempotent, over TCP) -----------------------------------
# Exists in both modes already (local: step 0; remote: POSTGRES_USER of the
# postgres image) — here only password and privileges are synchronized.
"${PSQL[@]}" -d postgres <<SQL
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '${DB_USER}') THEN
    CREATE ROLE ${DB_USER} SUPERUSER CREATEDB LOGIN PASSWORD '${DB_PASSWORD}';
  ELSE
    ALTER ROLE ${DB_USER} WITH SUPERUSER CREATEDB LOGIN PASSWORD '${DB_PASSWORD}';
  END IF;
END
\$\$;
SQL

# --- 3. Ensure database 'root' (root_user.yml) --------------------------------------------
DB_ROOT_EXISTS=$("${PSQL[@]}" -d postgres -AXtqc "SELECT 1 FROM pg_database WHERE datname='root'")
if [ "${DB_ROOT_EXISTS}" != "1" ]; then
  "${PSQL[@]}" -d postgres -qc "CREATE DATABASE root OWNER ${DB_USER}"
  log "database 'root' created"
fi

# --- 4. Create the leihs database + structure/seeds (create-and-seed.yml) -----------------
DB_EXISTS=$("${PSQL[@]}" -d postgres -AXtqc "SELECT 1 FROM pg_database WHERE datname='${DB_NAME}'")
if [ "${DB_EXISTS}" != "1" ]; then
  log "database '${DB_NAME}' does not exist — creating (ICU de-CH, UTF8, template0)"
  "${PSQL[@]}" -d postgres -qc "CREATE DATABASE ${DB_NAME} OWNER ${DB_USER} ENCODING 'UTF8' TEMPLATE template0 LOCALE_PROVIDER icu ICU_LOCALE 'de-CH'"

  log "loading structure.sql"
  "${PSQL[@]}" -d "${DB_NAME}" -f "${LEIHS_ROOT_DIR}/database/db/structure.sql"

  log "loading seeds.sql (session_replication_role=REPLICA)"
  "${PSQL[@]}" -d "${DB_NAME}" \
    -c "SET session_replication_role = REPLICA;" \
    -f "${LEIHS_ROOT_DIR}/database/db/seeds.sql" \
    -c "SET session_replication_role = DEFAULT;"
  log "database '${DB_NAME}' initialized (structure + seeds)"
else
  log "database '${DB_NAME}' already exists — skipping structure/seeds"
fi

# --- 5. Migrations (leihs-migration.service) ------------------------------------------------
log "running migrations (rake db:migrate)"
cd "${LEIHS_ROOT_DIR}/database"
set -a
# shellcheck disable=SC1091
source /etc/leihs/config.env
set +a
export RAILS_ENV=production
export LEIHS_SECRET="${LEIHS_MASTER_SECRET}"
export SECRET_KEY_BASE="${LEIHS_MASTER_SECRET}"
export RAILS_LOG_LEVEL=WARN
export PATH="/opt/ruby/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
bundle exec rake db:migrate
log "migrations complete"

#!/usr/bin/env bash
#
# render-config.sh — renders all leihs configuration from environment variables.
#
# Corresponds to the Ansible templates from leihs_deploy (roles/configure,
# roles/leihs-legacy-install, roles/reverse-proxy-leihs, roles/webstats).
#
set -euo pipefail

log() { echo "[leihs:config] $*"; }

mkdir -p /etc/leihs /etc/apache2/leihs/conf.d "${LEIHS_ROOT_DIR}/config" /var/log/leihs

# ---------------------------------------------------------------------------
# /etc/leihs/config.env — environment for all Java services (config.env template)
# ---------------------------------------------------------------------------
cat > /etc/leihs/config.env <<EOF
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT}
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}

ENABLE_AUTH_HEADER_PREFIX_BASIC=${ENABLE_AUTH_HEADER_PREFIX_BASIC}

LEIHS_VERSION=${LEIHS_VERSION}
EOF
chmod 600 /etc/leihs/config.env
log "config.env written"

# ---------------------------------------------------------------------------
# /leihs/config/database.yml — central DB config (configure role)
# ---------------------------------------------------------------------------
cat > "${LEIHS_ROOT_DIR}/config/database.yml" <<EOF
database:
	host: ${DB_HOST}
	port: ${DB_PORT}
	username: ${DB_USER}
	password: ${DB_PASSWORD}
	database: ${DB_NAME}
EOF
chmod 600 "${LEIHS_ROOT_DIR}/config/database.yml"

# ---------------------------------------------------------------------------
# /leihs/legacy/config/database.yml (leihs-legacy-install database.yml)
# ---------------------------------------------------------------------------
cat > "${LEIHS_ROOT_DIR}/legacy/config/database.yml" <<EOF
production:
  adapter: postgresql
  host: ${DB_HOST}
  port: ${DB_PORT}
  pool: 25
  encoding: unicode
  username: ${DB_USER}
  password: ${DB_PASSWORD}
  database: ${DB_NAME}
EOF
chmod 600 "${LEIHS_ROOT_DIR}/legacy/config/database.yml"
log "database.yml written"

# ---------------------------------------------------------------------------
# /leihs/database/config/database.yml (leihs-database-install database.yml)
# Used by the migration app (rake db:migrate).
# ---------------------------------------------------------------------------
mkdir -p "${LEIHS_ROOT_DIR}/database/config"
cat > "${LEIHS_ROOT_DIR}/database/config/database.yml" <<EOF
production: &DEFAULT
  adapter: postgresql
  host: ${DB_HOST}
  port: ${DB_PORT}
  pool: 25
  encoding: unicode
  username: ${DB_USER}
  password: ${DB_PASSWORD}
  database: ${DB_NAME}
development:
  <<: *DEFAULT
EOF
chmod 600 "${LEIHS_ROOT_DIR}/database/config/database.yml"
log "database.yml (database app) written"

# ---------------------------------------------------------------------------
# /leihs/legacy/config/puma.rb (puma.rb template)
# ---------------------------------------------------------------------------
cat > "${LEIHS_ROOT_DIR}/legacy/config/puma.rb" <<EOF
workers(${LEIHS_PUMA_WORKERS})
threads(1,${LEIHS_PUMA_THREADS})
bind("tcp://localhost:${LEIHS_LEGACY_HTTP_PORT}")
environment("production")
EOF
log "puma.rb written (workers=${LEIHS_PUMA_WORKERS}, threads=${LEIHS_PUMA_THREADS})"

# ---------------------------------------------------------------------------
# Apache2: directories + modules + default certificate
# ---------------------------------------------------------------------------
mkdir -p /etc/apache2/leihs/conf.d /var/run/apache2 /var/lock/apache2
if [ ! -e /etc/ssl/private/ssl-cert-snakeoil.key ]; then
  make-ssl-cert generate-default-snakeoil --force-overwrite 2>/dev/null || true
fi

# Main config (leihs-main.conf): render IP_HASH_SEED + inventory route
SEED="${LEIHS_IP_HASH_SEED:-$(hostname)}"
sed "s|__IP_HASH_SEED__|${SEED}|g" /etc/apache2/leihs/leihs-main.conf > /etc/apache2/leihs/leihs-main.conf.rendered
if [ "${PUBLISH_INVENTORY}" = "true" ]; then
  sed -i "s|^#\?\s*ProxyPass /inventory|ProxyPass /inventory|" /etc/apache2/leihs/leihs-main.conf.rendered
else
  sed -i "s|^ProxyPass /inventory|#ProxyPass /inventory|" /etc/apache2/leihs/leihs-main.conf.rendered
fi
mv /etc/apache2/leihs/leihs-main.conf.rendered /etc/apache2/leihs/leihs-main.conf

# Virtual hosts (http.conf/https.conf templates)
sed "s|__LEIHS_EXTERNAL_HOSTNAME__|${LEIHS_EXTERNAL_HOSTNAME}|g" \
    /etc/apache2/leihs/vhost-http.conf.tpl > /etc/apache2/sites-available/leihs-http.conf
sed "s|__LEIHS_EXTERNAL_HOSTNAME__|${LEIHS_EXTERNAL_HOSTNAME}|g" \
    /etc/apache2/leihs/vhost-https.conf.tpl > /etc/apache2/sites-available/leihs-https.conf

# conf.d fragments (included from both vhosts)
rm -f /etc/apache2/leihs/conf.d/*.conf

# Webstats (webstats.conf) — optional, default on
if [ "${WEBSTATS_ENABLED}" = "true" ]; then
  cp /etc/apache2/leihs/webstats.conf /etc/apache2/leihs/conf.d/leihs_100_webstats.conf
  # adjust awstats configuration (like the webstats role)
  sed -i "s|^LogFile=.*|LogFile=\"/var/log/apache2/leihs_${LEIHS_EXTERNAL_HOSTNAME}_access.log\"|" /etc/awstats/awstats.conf
  sed -i "s|^SiteDomain=.*|SiteDomain=\"${LEIHS_EXTERNAL_HOSTNAME}\"|" /etc/awstats/awstats.conf
  log "webstats enabled"
else
  log "webstats disabled"
fi

# Basic auth (optional, default off)
if [ "${RESTRICT_ACCESS_VIA_BASIC_AUTH}" = "true" ]; then
  sed "s|__LEIHS_EXTERNAL_HOSTNAME__|${LEIHS_EXTERNAL_HOSTNAME}|g" \
      /etc/apache2/leihs/basic-auth.conf.tpl > /etc/apache2/leihs/conf.d/leihs_950_basic_auth.conf
  : > /etc/leihs/leihs.htpasswd
  # Format: "user:pass,user2:pass2"
  IFS=',' read -ra ENTRIES <<< "${RESTRICT_ACCESS_VIA_BASIC_AUTH_PASSWORDS}"
  for entry in "${ENTRIES[@]}"; do
    user="${entry%%:*}"
    pass="${entry#*:}"
    [ -n "${user}" ] && htpasswd -b /etc/leihs/leihs.htpasswd "${user}" "${pass}"
  done
  log "basic auth enabled (${#ENTRIES[@]} users)"
else
  log "basic auth disabled"
fi

# a2ensite + configuration test
a2ensite leihs-http >/dev/null 2>&1 || true
a2ensite leihs-https >/dev/null 2>&1 || true
a2dissite 000-default >/dev/null 2>&1 || true
apache2ctl -t >/dev/null 2>&1 || { echo "[leihs:config] Apache config test failed:"; apache2ctl -t; exit 1; }
log "Apache configuration valid"

# ---------------------------------------------------------------------------
# Ensure directories (logs/tmp)
# ---------------------------------------------------------------------------
mkdir -p "${LEIHS_ROOT_DIR}/legacy/log" "${LEIHS_ROOT_DIR}/legacy/tmp" "${LEIHS_ROOT_DIR}/legacy/storage"
mkdir -p "${LEIHS_ROOT_DIR}/database/log" "${LEIHS_ROOT_DIR}/database/tmp"
for svc in admin borrow procure my mail inventory; do
  mkdir -p "${LEIHS_ROOT_DIR}/${svc}/logs" "${LEIHS_ROOT_DIR}/${svc}/tmp"
done
mkdir -p "${LEIHS_ROOT_DIR}/var/db-backups"
log "directories created"

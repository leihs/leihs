# leihs-docker

Docker deployment for **[leihs](https://github.com/leihs/leihs)** — the
equipment booking & inventory management system by ZHdK (GPLv3).

This directory converts the official **Ansible installation**
([leihs/leihs_deploy](https://github.com/leihs/leihs_deploy)) to Docker.
The image contains PostgreSQL 15, an Apache2 reverse proxy and all leihs
services (legacy, database, admin, borrow, procure, my, mail, inventory) —
mirroring the single-machine layout of the Ansible deployment. The
`compose.yaml` additionally offers a **split mode**: PostgreSQL as its own
container (recommended). The app talks to the database over TCP via
`DB_HOST`/`DB_PORT` in both modes.

> This is a contribution proposal to the leihs project. A maintained
> reference implementation lives in the
> [leihs-docker](https://github.com/tilllt/leihs-docker) repository (public
> mirror of a private repo).

---

## 1. Architecture

**Split mode (compose default):**

```
                        ┌──────────────────────────────────────────┐
 Browser ── 80/443 ──►  │  Apache2 (reverse proxy, mod_proxy)      │
                        │  ├─ /            → leihs-my        :3240  │
                        │  ├─ /admin       → leihs-admin     :3220  │
                        │  ├─ /borrow      → leihs-borrow    :3250  │
                        │  ├─ /procure     → leihs-procure   :3230  │
                        │  ├─ /inventory   → leihs-inventory :3260  │  (optional)
                        │  ├─ /assets      → static (legacy/public)│
                        │  └─ /status …    → leihs-legacy    :3210  │
                        └───────────────┬──────────────────────────┘
                                        │ TCP db:5415 (internal network)
                        ┌───────────────▼──────────────────────────┐
                        │  container "db" (postgres:15, port 5415) │
                        │  DB leihs, role root                     │
                        └──────────────────────────────────────────┘
   leihs-mail (no HTTP port, worker)  │  leihs-legacy-cron (daily 04:00)
```

**Single-container mode** (`DB_HOST=localhost`, image alone): identical
layout, but the bundled PostgreSQL (pgdg, port 5415) runs in the same
container instead of the `db` service.

All client connections (Rails `database.yml`, Java services via
`config.env`, `init-db.sh`) always go **over TCP** against
`DB_HOST:DB_PORT` — a single code path for both modes. The local cluster is
only started by `init-db.sh` when `DB_HOST` points to `localhost`.

## 2. How it works

The image is built in two stages:

- **Stage `build`** (debian:bookworm-slim + [mise](https://mise.jdx.dev/)):
  clones the `leihs/leihs` super-repo at the pinned `LEIHS_REF` (default
  `master`) including all submodules, installs the exact toolchain from
  `.tool-versions` (Ruby 3.3.8, Java Temurin 21, Node, Clojure), builds the
  Clojure fat jars (`./bin/build`) and installs the Ruby gems for `legacy`
  and `database` into `vendor/bundle`.
- **Stage `runtime`** (debian:bookworm-slim): PostgreSQL 15 from the pgdg
  repo (like `roles/postgresql`, port 5415), Apache2 with all proxy modules,
  Ruby/Java copied from the build stage, all leihs apps under `/leihs/…`.

On container start (`entrypoint.sh`) the exact step sequence of the Ansible
deployment runs (all steps are idempotent):

| Step | Ansible equivalent | Implementation |
|---|---|---|
| 1. Defaults | `defaults.yml` | env variables with identical defaults |
| 2. Master secret | `roles/configure` (`master_secret.txt`) | auto-generated & persisted in `/leihs/var/master_secret` |
| 3. Render config | `roles/configure`, `roles/leihs-legacy-install`, `roles/reverse-proxy-leihs`, `roles/webstats` | `scripts/render-config.sh`: `config.env` (incl. `DB_HOST`), `database.yml` (legacy **and** database app), `puma.rb`, Apache vhosts, AWStats |
| 4. Init DB | `roles/postgresql` + `roles/leihs-database-install` | `scripts/init-db.sh`: client steps (role `root` SUPERUSER/CREATEDB, DB `root`, DB `leihs` with ICU `de-CH`/UTF8/template0, `structure.sql` + `seeds.sql` with `session_replication_role=REPLICA`) always over TCP against `DB_HOST:DB_PORT`; the bundled cluster is only created/started when `DB_HOST=localhost` |
| 5. Migrations | `leihs-migration.service` (oneshot) | `bundle exec rake db:migrate` in `/leihs/database` (RAILS_ENV=production) |
| 6. Start services | `roles/start-services` + systemd units | `scripts/start-services.sh`: supervisor with restart loops (systemd `Restart=always` behavior), Apache + Puma + jars + cron loop, clean SIGTERM handling |

## 3. Quick start

```bash
# Configuration (optional — all values have defaults):
cp docker/example.env .env        # adjust, e.g. LEIHS_EXTERNAL_HOSTNAME, DB_PASSWORD

# Variant A: docker compose — split mode (PostgreSQL as its own container)
docker compose -f docker/compose.yaml up -d
docker compose -f docker/compose.yaml logs -f

# Variant B: docker run — single-container mode (bundled PostgreSQL)
docker build -t leihs-docker:latest docker/
docker run -d --name leihs \
  -p 80:80 -p 443:443 \
  -e LEIHS_EXTERNAL_HOSTNAME=leihs.example.org \
  -e DB_HOST=localhost \
  -v pgdata:/var/lib/postgresql \
  -v leihs-data:/leihs/var \
  -v leihs-storage:/leihs/legacy/storage \
  leihs-docker:latest
```

The only difference between the modes is `DB_HOST`: `db` (compose, split) or
`localhost` (single container). `init-db.sh` initializes the database over
TCP in both cases — the role `root`, the database `leihs` (ICU `de-CH`) and
`structure.sql`/`seeds.sql` are created automatically.

Afterwards:

- `http://localhost/` → leihs-my (login page)
- `http://localhost/admin` → admin
- `http://localhost/borrow` → borrow (booking)
- `http://localhost/status` → health check route (legacy)
- Initial login data: see the
  [leihs wiki (live demo accounts)](https://github.com/leihs/leihs/wiki#live-demo)
  — the seeds (admin users) come from `seeds.sql` of the `leihs_database` repo.

**Important first configuration:** change `DB_PASSWORD` (or set
`LEIHS_MASTER_SECRET`), set `LEIHS_EXTERNAL_HOSTNAME` to the real hostname,
and configure SMTP via the admin UI (mail settings live in the `smtp_settings`
table, as in the Ansible deployment).

## 4. Environment variables

| Variable | Default | Description |
|---|---|---|
| `LEIHS_EXTERNAL_HOSTNAME` | `leihs.example.org` | ServerName of the vhosts |
| `LEIHS_MASTER_SECRET` | auto-generated | Rails/jar secret (40 chars); persisted under `/leihs/var/master_secret` |
| `DB_HOST` / `DB_PORT` | `db` / `5415` | PostgreSQL connection (compose: service name `db`; single container: `localhost`). All clients use TCP |
| `DB_NAME` / `DB_USER` / `DB_PASSWORD` | `leihs` / `root` / `root` | **Change the password in production!** |
| `PUBLISH_INVENTORY` | `false` | `true` starts the inventory service and enables the `/inventory` route |
| `ENABLE_AUTH_HEADER_PREFIX_BASIC` | `true` | `ENABLE_AUTH_HEADER_PREFIX_BASIC` in config.env |
| `RESTRICT_ACCESS_VIA_BASIC_AUTH` | `false` | protect the whole access with basic auth |
| `RESTRICT_ACCESS_VIA_BASIC_AUTH_PASSWORDS` | — | `"user:pass,user2:pass2"` |
| `WEBSTATS_ENABLED` | `true` | AWStats under `/webstats` |
| `LEIHS_PUMA_WORKERS` / `LEIHS_PUMA_THREADS` | `2` / `5` | Puma workers/threads (Ansible: vCPUs / 5) |
| `LEIHS_CRON_TIME` | `04:00` | daily `rake leihs:cron` run |
| `LEIHS_CRON_RANDOMIZED_DELAY_MAX_SECONDS` | `3600` | random delay (Ansible default) |
| `LEIHS_JAVA_XMX_<SERVICE>` | 1G / 500m | heap size per jar (Ansible defaults) |
| `LEIHS_DB_MAX_POOL_SIZE` | `20` | DB pool of the jars (my/mail: 10) |
| `LEIHS_IP_HASH_SEED` | hostname | seed for IP anonymization in the access log |

## 5. Persistent data (volumes)

| Volume | Content |
|---|---|
| `pgdata` | PostgreSQL cluster (database `leihs`) — split mode: on the `db` service (`/var/lib/postgresql/data`); single-container mode: on the app container (`/var/lib/postgresql`) |
| `leihs-data` | `master_secret`, DB backups, IP hash seed |
| `leihs-storage` | ActiveStorage uploads (images, attachments) |

## 6. Backup & restore

```bash
# Split mode: directly against the DB container
docker exec leihs-db pg_dump -U root -d leihs > leihs-$(date +%F).sql

# Single-container mode: inside the app container
docker exec leihs pg_dump -h localhost -p 5415 -U root leihs > leihs-$(date +%F).sql

# Additionally back up the uploads:
docker cp leihs:/leihs/legacy/storage ./storage
```

Restore:

```bash
# Split mode
docker exec -i leihs-db psql -U root -d leihs < leihs-2026-01-01.sql

# Single-container mode
docker exec -i leihs psql -h localhost -p 5415 -U root leihs < leihs-2026-01-01.sql
```

**Migrating single container → split:** dump once from the old system, then
`docker compose -f docker/compose.yaml up -d` (the `db` container starts
empty) and restore as above.

## 7. Differences to the Ansible deployment (by design)

- **No system users** (`leihs-legacy`, `leihs-admin`, …): the container runs
  as root; Docker provides the isolation.
- **No SSH/Ansible control plane:** deployment = image build + container
  start; "redeploy" = `docker compose pull && up -d`.
- **`leihs_inventory`** is optional (default off), as in the Ansible deploy.
- **DB backup** is not built in — `pg_dump` from outside (see §6).
- **PostgreSQL split** is an additional option: the bundled PostgreSQL stays
  for the single-container mode; the compose default runs PostgreSQL as its
  own container on the internal network (no port exposed to the host).

## 8. Running the container non-root (optional)

By default the container runs as root, mirroring the Ansible deployment.
To run the container processes without root (UID 1000, **not** Rootless
Docker — the daemon stays root), the following changes are needed:

**Dockerfile:**
```dockerfile
RUN useradd -r -u 1000 -m -s /bin/bash leihs
# writable paths + PostgreSQL data dir, owned by the user (named volumes
# inherit the image ownership on first use)
RUN chown -R leihs:leihs /leihs /etc/leihs /var/log/leihs \
      /run/apache2 /var/lock/apache2 /var/cache/apache2 \
      /etc/apache2/sites-available /etc/apache2/sites-enabled \
      /etc/awstats/awstats.conf /var/lib/postgresql
RUN usermod -aG ssl-cert leihs     # read the snakeoil private key
# ...
USER leihs
```

**`init-db.sh`:** replace the Debian cluster wrappers (root-only
`pg_createcluster`/`pg_ctlcluster`) with a user-space `initdb` + `pg_ctl`;
the bootstrap superuser becomes the app user itself:
```bash
initdb -D "${PGDATA}" -U "${DB_USER}" -E UTF8 --locale=C.UTF-8 \
  --pwfile=<(printf '%s' "${DB_PASSWORD}") \
  --auth-host=scram-sha-256 --auth-local=trust
echo "port = ${DB_PORT}" >> "${PGDATA}/postgresql.conf"   # 5415 > 1024
pg_ctl -D "${PGDATA}" -o "-p ${DB_PORT} -k /tmp" -w start
```
The `su postgres` peer-auth bootstrap is dropped entirely; all client steps
already run over TCP. In split mode this block is inactive anyway.

**Apache:** either render high ports (8080/8443, mapped to 80/443 in
compose), or keep 80/443 with a file capability:
`RUN setcap cap_net_bind_service=+ep /usr/sbin/apache2`
(`NET_BIND_SERVICE` is in the Docker default capability set).

**compose:** `user: "1000:1000"` on both services (plus optional
`read_only`, `tmpfs`, `cap_drop: [ALL]`, `no-new-privileges`).
**Volume pitfall:** named volumes inherit the image ownership on first use —
for a non-root `postgres:15` use a bind mount pre-owned by UID 1000 or
chown the volume once via a temporary root helper container.

**Verify:** `docker exec leihs id` → `uid=1000(leihs)`;
`psql -h 127.0.0.1 -p 5415 -U root -d leihs -c "select 1"`.

**Limits:** this is *not* Rootless Docker (the daemon remains root), and
`setcap` is a small privilege extension. The image default stays root for
compatibility; non-root is a documented option.

**Trade-offs to be aware of:**
- **Ongoing maintenance:** the Ansible reference deployment runs as root;
  non-root is a permanent delta branch — every upstream change needs an
  ownership review.
- **Upgrade path:** existing root-run volumes are root-owned; switching to
  non-root requires a one-time `chown` (via a temporary root helper
  container). Named volumes inherit the image ownership only on first use.
- **`setcap` conflicts with `no-new-privileges`:** `no_new_privs` prevents
  file capabilities from being granted at `exec` — with
  `no-new-privileges:true` Apache cannot bind 80/443 even with `setcap`
  (use the high-port variant instead).
- **TLS certificates:** certbot/Let's-Encrypt typically runs as root;
  renewal must move outside the container (host cron + read-only mount).
- **No boundary against the host:** without user namespaces, UID 1000 in
  the container maps to UID 1000 on the host — relevant for bind mounts on
  multi-user hosts. Real isolation would require rootless/userns-remap.

## 9. Troubleshooting

| Symptom | Cause / fix |
|---|---|
| Container starts, healthcheck green, but `/` does not load | Puma needs up to ~60 s; check `docker logs leihs` |
| `502` on `/inventory` | `PUBLISH_INVENTORY` is `false` (service not running) |
| Login fails / sessions broken | `LEIHS_MASTER_SECRET` changed → keep the secret in `/leihs/var/master_secret` or env stable |
| DB init fails | leave volumes empty or back up the DB consistently; `docker logs` shows the exact step |
| `db` container not ready | `docker compose -f docker/compose.yaml logs db`; healthcheck runs `pg_isready` (port `DB_PORT`, `start_period` 30 s) |
| Migration error | `docker compose -f docker/compose.yaml exec leihs bash -lc 'cd /leihs/database && RAILS_ENV=production bundle exec rake db:migrate'` |
| Apache config error on start | `docker exec leihs apache2ctl -t` |

# syntax=docker/dockerfile:1
#
# leihs-docker — All-in-one container image for leihs
# (equipment booking & inventory management system, https://github.com/leihs/leihs)
#
# This image reproduces the single-server installation of the official
# Ansible deployment (https://github.com/leihs/leihs_deploy) in a container:
# PostgreSQL 15 + Apache2 reverse proxy + all leihs services.
#
# The source is the leihs/leihs super-repository (pinning all service
# submodules: legacy, database, admin, borrow, procure, my, mail, inventory)
# at exactly the revision the Ansible deployment would deploy.
#
# Build arguments:
#   LEIHS_REF      Branch/tag/commit of the leihs super-repo (default: master)
#   LEIHS_VERSION  Version string for config.env / display (default: unknown)
#   BASE_IMAGE     Base image (default: debian:bookworm-slim)
#
# Build (context = this directory):
#   docker build -t leihs-docker:latest docker/
#
# The build clones the super-repo from GitHub at build time (including all
# submodules), so the build context itself needs no source files.

ARG BASE_IMAGE=debian:bookworm-slim

###############################################################################
# Stage 1: build — toolchain (mise) + source + build all artifacts          #
###############################################################################
FROM ${BASE_IMAGE} AS build

ARG LEIHS_REF=master
ARG LEIHS_VERSION=unknown
ARG DEBIAN_FRONTEND=noninteractive

# --- System build dependencies --------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl git gnupg jq \
        build-essential pkg-config unzip xz-utils \
        libpq-dev libyaml-dev libreadline-dev zlib1g-dev libssl-dev \
        libffi-dev libgdbm-dev libncurses-dev libxml2-dev libxslt1-dev \
        shared-mime-info \
    && rm -rf /var/lib/apt/lists/*

# --- mise (version manager used by the leihs build scripts) ---------------------
RUN curl -fsSL https://mise.jdx.dev/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

# --- Source checkout --------------------------------------------------------------
# leihs super-repo including all submodules (legacy, database, admin, borrow,
# procure, my, mail, inventory, ...). --depth 1 saves time; when LEIHS_REF is a
# commit SHA it is fetched afterwards.
WORKDIR /src
RUN if [ "${LEIHS_REF}" = "master" ]; then \
        git clone --depth 1 https://github.com/leihs/leihs.git /src/leihs; \
    else \
        git clone --depth 1 --branch "${LEIHS_REF}" https://github.com/leihs/leihs.git /src/leihs \
        || ( git clone --depth 1 https://github.com/leihs/leihs.git /src/leihs \
             && cd /src/leihs && git fetch --depth 1 origin "${LEIHS_REF}" && git checkout FETCH_HEAD ); \
    fi \
    && cd /src/leihs \
    && git submodule update --init --recursive --depth 1 \
    && (git describe --tags --always || true) > /tmp/leihs_version_actual \
    && printf '%s' "${LEIHS_VERSION}" > /tmp/leihs_version_arg

# --- Install the toolchain from .tool-versions (single source of truth) ----------
# Root .tool-versions: babashka, clojure, java temurin-21, nodejs, ruby 3.3.8.
# Some sub-projects pin different nodejs versions — those are installed
# explicitly below. firefox/geckodriver (tests only) are intentionally NOT
# installed; the build scripts do not call them.
RUN cd /src/leihs && mise install
RUN for d in admin borrow procure my mail inventory legacy database; do \
        cd /src/leihs/${d} && mise install nodejs ruby >/dev/null; \
    done

# --- Clojure/JS services: ./bin/build produces the fat jars -----------------------
# (bin/build internally runs `mise install ruby` + `bundle install`)
RUN cd /src/leihs/admin     && mise exec -- ./bin/build
RUN cd /src/leihs/borrow    && mise exec -- ./bin/build
RUN cd /src/leihs/procure   && mise exec -- ./bin/build
RUN cd /src/leihs/my        && mise exec -- ./bin/build
RUN cd /src/leihs/mail      && mise exec -- ./bin/build
RUN cd /src/leihs/inventory && mise exec -- ./bin/build

# --- Ruby apps: bundle install (legacy + database) ---------------------------------
# Local into vendor/bundle so the gems are carried over into the runtime image.
RUN cd /src/leihs/legacy   && mise exec -- bundle config set --local path vendor/bundle \
    && mise exec -- bundle install
RUN cd /src/leihs/database && mise exec -- bundle config set --local path vendor/bundle \
    && mise exec -- bundle install

###############################################################################
# Stage 2: runtime — PostgreSQL + Apache + Ruby + Java + leihs                #
###############################################################################
FROM ${BASE_IMAGE} AS runtime

ARG POSTGRES_VERSION=15
ARG LEIHS_VERSION=unknown
ARG DEBIAN_FRONTEND=noninteractive
ENV LEIHS_VERSION_BUILD=${LEIHS_VERSION}

# --- Base packages ---------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg locales procps tzdata \
        apache2 ssl-cert awstats \
        libyaml-0-2 libssl3 zlib1g libffi8 libgdbm6 libreadline8 libncursesw6 \
        libpq5 libxml2 libxslt1.1 shared-mime-info \
        fontconfig fonts-liberation \
    && rm -rf /var/lib/apt/lists/* \
    && echo "de_CH.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen

# --- PostgreSQL ${POSTGRES_VERSION} from the pgdg repo (like the Ansible deploy) --
RUN install -d /etc/apt/keyrings \
    && curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/keyrings/pgdg.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/pgdg.gpg] https://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-${POSTGRES_VERSION} postgresql-client-${POSTGRES_VERSION} \
    && rm -rf /var/lib/apt/lists/* \
    && PGCONF=$(find /etc/postgresql -name postgresql.conf | head -1) \
    && sed -i "s/^#\?port = .*/port = 5415/" "${PGCONF}"

# --- Ruby + Java from the build stage (exact .tool-versions versions) --------------
COPY --from=build /root/.local/share/mise/installs/ruby/* /opt/mise/ruby/
COPY --from=build /root/.local/share/mise/installs/java/* /opt/mise/java/
RUN RUBY_DIR=$(ls -d /opt/mise/ruby/*/ | head -1) \
    && JAVA_DIR=$(ls -d /opt/mise/java/*/ | head -1) \
    && ln -s "${RUBY_DIR%/}" /opt/ruby \
    && ln -s "${JAVA_DIR%/}" /opt/java
ENV PATH="/opt/ruby/bin:/opt/java/bin:${PATH}" \
    JAVA_HOME=/opt/java

# --- leihs apps: legacy + database (complete), services as jars ---------------------
COPY --from=build /src/leihs/legacy /leihs/legacy
COPY --from=build /src/leihs/database /leihs/database
COPY --from=build /src/leihs/admin/target/leihs-admin.jar         /leihs/admin/leihs-admin.jar
COPY --from=build /src/leihs/borrow/target/leihs-borrow.jar       /leihs/borrow/leihs-borrow.jar
COPY --from=build /src/leihs/procure/server/target/leihs-procure.jar /leihs/procure/leihs-procure.jar
COPY --from=build /src/leihs/my/target/leihs-my.jar               /leihs/my/leihs-my.jar
COPY --from=build /src/leihs/mail/target/leihs-mail.jar           /leihs/mail/leihs-mail.jar
COPY --from=build /src/leihs/inventory/target/leihs-inventory.jar /leihs/inventory/leihs-inventory.jar
RUN rm -rf /leihs/legacy/.git /leihs/database/.git \
    && mkdir -p /leihs/legacy/{log,tmp,storage,public/system} \
    && mkdir -p /leihs/database/{log,tmp} \
    && mkdir -p /leihs/{admin,borrow,procure,my,mail,inventory}/{logs,tmp} \
    && mkdir -p /leihs/var/db-backups /leihs/config /var/log/leihs /etc/leihs

# --- Entrypoint, scripts, Apache configuration --------------------------------------
COPY entrypoint.sh /usr/local/bin/leihs-entrypoint
COPY scripts/ /usr/local/lib/leihs/
COPY apache/ /etc/apache2/leihs/
RUN chmod +x /usr/local/bin/leihs-entrypoint /usr/local/lib/leihs/*.sh \
    && a2enmod proxy proxy_http rewrite alias headers expires ssl cache cache_disk unique_id setenvif env cgid

# --- Ports & healthcheck --------------------------------------------------------------
EXPOSE 80 443
HEALTHCHECK --interval=30s --timeout=5s --start-period=300s --retries=3 \
    CMD curl -fsS "http://localhost/status" >/dev/null 2>&1 || exit 1

ENTRYPOINT ["/usr/local/bin/leihs-entrypoint"]

# Volumes (persistent data):
#   /var/lib/postgresql          PostgreSQL data
#   /leihs/var                   master_secret, DB backups
#   /leihs/legacy/storage        ActiveStorage uploads (images, attachments)
VOLUME ["/var/lib/postgresql", "/leihs/var", "/leihs/legacy/storage"]

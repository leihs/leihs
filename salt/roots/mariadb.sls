mariadb:
  pkgrepo.managed:
    - humanname: MariaDB
    - name: deb http://mirror.netcologne.de/mariadb/repo/5.5/debian wheezy main
    - dist: wheezy
    - file: /etc/apt/sources.list.d/mariadb.list
    - keyid: 1BB943DB
    - keyserver: keyserver.ubuntu.com
    - require_in:
      - pkg: mariadb-client
      - pkg: mariadb-server
      - pkg: libmariadbclient-dev
      - pkg: libmariadbclient18

mariadb-client:
  pkg:
    - installed
    - refresh: True

mariadb-server:
  pkg:
    - installed
    - refresh: True

libmariadbclient-dev:
  pkg:
    - installed
    - refresh: True

libmariadbclient18:
  pkg:
    - installed
    - refresh: True

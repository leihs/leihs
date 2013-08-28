base:
  pkgrepo.managed:
    - humanname: iceweasel updates for Debian
    - name: deb http://mozilla.debian.net/ wheezy-backports iceweasel-release
    - dist: wheezy-backports
    - file: /etc/apt/sources.list.d/iceweasel.list
    - require_in:
      - pkg: iceweasel

pkg-mozilla-archive-keyring:
  pkg:
    - installed

iceweasel:
  pkg:
    - installed

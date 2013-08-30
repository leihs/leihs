/etc/apache2/sites-available/leihs:
  file.managed:
    - source:
      - salt://leihs
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: passenger-snippet

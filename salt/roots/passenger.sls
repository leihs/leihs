passenger:
  gem.installed:
    - ruby: ruby-1.9.3
    - runas: vagrant

passenger-install-apache2-module:
  cmd.run:
    - name: passenger-install-apache2-module -a
    - user: vagrant
    - cwd: /home/vagrant
    - require:
      - gem: passenger

passenger-snippet:
  cmd.run:
    - name: passenger-install-apache2-module --snippet > /srv/salt/passenger.load
    - user: vagrant
    - cwd: /home/vagrant
    - require:
      - cmd: passenger-install-apache2-module

/etc/apache2/mods-available/passenger.load:
  file.managed:
    - source:
      - salt://passenger.load
    - user: root
    - group: root
    - mode: 644
    - require:
      - cmd: passenger-snippet

enable-passenger-module:
  cmd.run:
    - name: a2enmod passenger
    - user: root
    - require:
      - file: /etc/apache2/mods-available/passenger.load

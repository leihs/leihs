passenger:
  gem.installed:
    - ruby: ruby-1.9.3
    - runas: vagrant

passenger-install-apache2-module:
  cmd.run:
    - name: passenger-install-apache2-module -a
    - unless: passenger-config --root
    - user: vagrant
    - cwd: /home/vagrant
    - requires:
      - gem.installed: passenger

passenger-snippet:
  cmd.run:
    - name: passenger-install-apache2-module --snippet > /srv/salt/passenger.load
    - user: vagrant
    - cwd: /home/vagrant
    - requires:
      - gem.installed: passenger
      - cmd.run: passenger-install-apache2-module

/etc/apache2/mods-available/passenger.load:
  file.managed:
    - source:
      - salt://passenger.load
    - user: root
    - group: root
    - mode: 644
    - requires:
      - cmd.run: passenger-snippet

enable-passenger-module:
  cmd.run:
    - name: a2enmod passenger
    - user: root
    - requires:
      - file.managed: /etc/apache2/mods-available/passenger.load

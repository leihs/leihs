#!/bin/bash

# The Ruby version you want to install and use for this Vagrant box
RUBY_VERSION=ruby-1.9.3-p448
PASSENGER_VERSION=3.0.9


##########  Packages and base requirements

# Always take this information from the official wiki: https://github.com/zhdk/leihs/wiki
# NOTE: Do not install mysql-server here, as that would ask for a password using a dialog, and we can't do that
# on the Vagrant shell.
sudo apt-get install --assume-yes build-essential make libxslt-dev libcairo2-dev libmysqlclient-dev libxml2-dev curl make build-essential git libxslt-dev libcairo2-dev libmysqlclient-dev libxml2-dev libreadline6-dev libssl-dev libyaml-dev autoconf libgdbm-dev libncurses5-dev automake libtool bison libffi-dev imagemagick libcurl4-openssl-dev apache2-prefork-dev apache2 mysql-client libmagickwand-dev

# Without this, installing MySQL will prompt for a MySQL root password, but we can't
# enter one in this noninteractive shell. With the noninteractive option set, the
# package will simply use a blank root password.
sudo DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes mysql-server



########## RVM, Ruby and bundler

# Only RVM is supported by Passenger. Cannot use rbenv.
# Also, only RVM has a good system-wide install.
if [ ! -f /usr/local/bin/rvm ]; then
        sudo curl -L https://get.rvm.io | bash -s stable
        sudo -i rvm install $RUBY_VERSION
fi

# Install or update Bundler
sudo -i "gem install bundler"


########## Passenger and Apache configuration

# Install Phusion Passenger
if [ ! -f /etc/apache2/mods-available/passenger.load ]; then
        sudo -i "gem install passenger -v $PASSENGER_VERSION"
        sudo -i "passenger-install-apache2-module"


PASSENGER=$(cat <<ENDPASSENGER
   LoadModule passenger_module /usr/local/rvm/gems/$RUBY_VERSION/gems/passenger-$PASSENGER_VERSION/ext/apache2/mod_passenger.so
   PassengerRoot /usr/local/rvm/gems/$RUBY_VERSION/gems/passenger-$PASSENGER_VERSION
   PassengerRuby /usr/local/rvm/wrappers/$RUBY_VERSION/ruby
ENDPASSENGER
)
        sudo echo "$PASSENGER" >> /etc/apache2/mods-available/passenger.load
        sudo a2enmod passenger
        sudo service apache2 restart

fi


# Enable the leihs virtual host
if [ ! -f /etc/apache2/sites-available/leihs ]; then
VHOST=$(cat <<ENDVHOST
<VirtualHost *:80>
   ServerName leihs.local
   DocumentRoot /vagrant/public/

   <Directory /vagrant/public>
      AllowOverride all
      Options -MultiViews
   </Directory>

</VirtualHost>
ENDVHOST
)

        echo "$VHOST" >> /etc/apache2/sites-available/leihs
        sudo a2ensite leihs
        sudo service apache2 restart
fi



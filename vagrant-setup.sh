#!/bin/bash

# The Ruby version you want to install and use for this Vagrant box
RUBY_VERSION=ruby-1.9.3-p448
PASSENGER_VERSION=3.0.9

sudo -i rvm install $RUBY_VERSION

# Install or update Bundler
rvmsudo gem install bundler

########## Passenger and Apache configuration

# Install Phusion Passenger
if [ ! -f /etc/apache2/mods-available/passenger.load ]; then
        rvmsudo gem install passenger -v $PASSENGER_VERSION
        rvmsudo passenger-install-apache2-module

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

        sudo echo "$VHOST" >> /etc/apache2/sites-available/leihs
        sudo a2ensite leihs
        sudo service apache2 restart
fi

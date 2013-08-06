#!/bin/bash


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
        sudo usermod -a -G rvm vagrant
fi


echo "################## WARNING #######################"
echo "################## WARNING #######################"
echo ""
echo "If this is the first time you use this Vagrant box,"
echo "you have to log in as user 'vagrant' and run the"
echo "/vagrant/vagrant-setup.sh script to continue."
echo ""
echo "################## WARNING #######################"
echo "################## WARNING #######################"

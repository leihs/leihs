#!/bin/bash

sudo apt-get install --assume-yes curl make build-essential git libxslt-dev libcairo2-dev libmysqlclient-dev libxml2-dev libreadline6-dev libssl-dev libyaml-dev autoconf libgdbm-dev libncurses5-dev automake libtool bison libffi-dev


# Without this, installing MySQL will prompt for a MySQL root password, but we can't
# enter one in this noninteractive shell. With the noninteractive option set, the
# package will simply use a blank root password.
sudo DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes mysql-server


# Check if the .rbenv directory already exists, because we might not have to install
# rbenv in such case.
if [ ! -d /home/vagrant/.rbenv ]; then
        git clone https://github.com/sstephenson/rbenv.git /home/vagrant/.rbenv
        git clone https://github.com/sstephenson/ruby-build.git /home/vagrant/.rbenv/plugins/ruby-build
        echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> /home/vagrant/.bash_profile
        echo 'eval "$(rbenv init -)"' >> /home/vagrant/.bash_profile
        chown -R vagrant /home/vagrant/.rbenv
        chown -R vagrant /home/vagrant/.bash_profile
fi


# su vagrant because by default it runs as root.
# bash -l because that creates a login shell, login shells process the .bash_profile files, non-login
# shells do not.
# TODO: Check if the required ruby version is already installed and skip this expensive
# step'.
su vagrant -c "bash -l -c 'rbenv rehash && rbenv install 1.9.3-p286 && rbenv global 1.9.3-p286'"

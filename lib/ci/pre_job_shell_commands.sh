#!/bin/bash --login

ln -s /var/lib/jenkins/configs/madek-log $WORKSPACE/log
mkdir -p $WORKSPACE/tmp/capybara
rm -rf $WORKSPACE/log && mkdir -p $WORKSPACE/log
rm -f $WORKSPACE/tmp/*.mysql
rm -f $WORKSPACE/tmp/*.sql
mkdir -p $WORKSPACE/tmp/html

rvm use 1.9.3
bundle install --without development
bundle exec rake madek:test:setup_ci_dbs
bundle exec rake madek:test:setup


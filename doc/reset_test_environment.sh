#!/bin/bash

sed -i 's/test/foo/' config/ferret_server.yml
RAILS_ENV='test' rake db:migrate:reset
sed -i 's/foo/test/' config/ferret_server.yml

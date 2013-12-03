#!/usr/bin/env ruby
require 'yaml'

$LOAD_PATH << './domina/lib'
require 'domina/database'

config = YAML.load_file("config/database.yml")["test"]
Domina::Database.drop_db config

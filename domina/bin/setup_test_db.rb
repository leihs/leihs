#!/usr/bin/env ruby
require 'yaml'

$LOAD_PATH << './domina/lib'
require 'domina/database'

config = YAML.load_file("config/database.yml")["test"]
Domina::Database.create_db config
Domina::Database.migrate_db

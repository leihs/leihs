#!/usr/bin/env ruby
require 'yaml'
require 'securerandom'

raise "env DOMINA_TRIAL_UUID must be set" unless ENV['DOMINA_TRIAL_UUID'] 
raise "env DOMINA_EXECUTION_UUID ust be set" unless ENV['DOMINA_EXECUTION_UUID'] 

def trial_id
  @_trial_id ||= (ENV['DOMINA_TRIAL_UUID'][0..7])
end

def execution_id
  @_execution_id ||= (ENV['DOMINA_EXECUTION_UUID'])[0..7]
end

config = YAML.load_file("config/database_domina.yml")
config["test"]["database"] = %Q[#{config["test"]["database"]}_#{trial_id}]

File.delete "config/database.yml" rescue nil

begin
  File.open("config/database.yml",'w'){|f| f.write(config.to_yaml)} 
rescue Exception => e
  puts "Couldn't write the config/database.yml file: #{e}"
  exit 1
end

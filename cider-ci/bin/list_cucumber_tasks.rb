#!/usr/bin/env ruby
require 'yaml'
require 'pry'

def task_for_feature_file file_path
  name= file_path.match(/features\/(.*)\.feature/).captures.first
  exec = %{bundle exec cucumber --strict "#{file_path}"}
  {"name" => name,
    "scripts" => {
    "cucumber" => {
    "body" => exec } } }
end

STDOUT.write \
  Dir.glob("features/**/*.feature") \
  .map{|f| task_for_feature_file(f)}.to_yaml

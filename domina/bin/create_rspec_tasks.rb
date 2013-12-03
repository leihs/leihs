#!/usr/bin/env ruby
require 'yaml'
require 'pry'

def task_for_rspec_file file_path
  name= file_path.match(/spec\/(.*)_spec\.rb/).captures.first.gsub(/\//,' ')
  exec = %{bundle exec rspec "#{file_path}"}
  {"name" => name,
    "scripts" => {
    "rspec" => {
    "body" => exec } } }
end

STDOUT.write \
  Dir.glob("spec/**/*_spec.rb") \
  .map{|f| task_for_rspec_file(f)}.to_yaml

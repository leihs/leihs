#!/usr/bin/env ruby
require 'yaml'
require 'set'

rspec_tasks = YAML.load_file "cider-ci/tasks/rspec.yml"

matcher= /.*rspec\s+\"(.*)\".*$/

tested_spec_files = Set.new rspec_tasks.map{|t| t['scripts']} \
  .map{|s| s['rspec']}.map{|s| s['body']}.map{|s|matcher.match(s)[1]}

existing_spec_files = Set.new Dir.glob("spec/**/*_spec.rb") 


if existing_spec_files == tested_spec_files
  puts "existing_spec_files and the tested_spec_files are equivalent"
  exit 0
else
  warn "existing_spec_files and the tested_spec_files are not equivalent: "
  warn "exiting but not tested: #{(existing_spec_files - tested_spec_files).map(&:to_s)}"
  warn "tested but not existing: #{(tested_spec_files - existing_spec_files).map(&:to_s)}"
  exit -1
end

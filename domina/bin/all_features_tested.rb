#!/usr/bin/env ruby
require 'yaml'
require 'set'

feature_tasks = YAML.load_file "domina/execution/feature_tasks.yml"

matcher= /.*cucumber.*\"(.*)\".*$/

tested_files = Set.new feature_tasks.map{|t| t['scripts']} \
  .map{|s| s['cucumber']}.map{|s| s['body']} \
  .map{|s| matcher.match(s)[1]}

existing_files = Set.new Dir.glob("features/**/*.feature") 


if existing_files == tested_files
  puts "existing_files and the tested_files are equivalent"
  exit 0
else
  warn "existing_files and the tested_files are not equivalent: "
  warn "exiting but not tested: #{(existing_files - tested_files).map(&:to_s)}"
  warn "tested but not existing: #{(tested_files - existing_files).map(&:to_s)}"
  exit -1
end

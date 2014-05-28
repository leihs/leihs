#!/usr/bin/env ruby
require 'yaml'
require 'pry'

def task_hash(name, exec, timeout = nil)
  h = { "name" => name,
        "scripts" => {
            "cucumber" => {
                "body" => exec
            }
        }
      }
  h["scripts"]["cucumber"]["timeout"] = timeout if timeout
  h
end

def task_for_feature_file file_path, timeout = 200, strict = false
  name= file_path.match(/features\/(.*)\.feature/).captures.first
  exec = %{bundle exec cucumber -p default #{strict ? "--strict " : nil}"#{file_path}"}
  task_hash(name, exec, timeout)
end

feature_files = Dir.glob("features/**/*.feature")

filepath = "./cider-ci/tasks/cucumber.yml"
File.open(filepath,"w") do |f|
  f.write(feature_files.map do |f|
    task_for_feature_file(f, 600)
  end.to_yaml)
end

filepath = "./cider-ci/tasks/cucumber_strict.yml"
File.open(filepath,"w") do |f|
  f.write(feature_files.map do |f|
    task_for_feature_file(f, 600, true)
  end.to_yaml)
end

filepath = "./cider-ci/tasks/cucumber_scenarios.yml"
File.open(filepath,"w") do |f|
  h = `egrep -R -n -B 1 "^\s*(Scenario|Szenario)" features/*`.split("--\n").map{|x| x.split("\n")}.map do |t, s|
    next if t =~ /@old-ui|@upcoming/
    splitted_string = s.split(/:\s*(Scenario|Szenario)( Outline| Template|grundriss)?: /)
    exec = %{bundle exec cucumber -p default "#{splitted_string.first}"}
    task_hash(splitted_string.last, exec)
  end.compact
  f.write h.to_yaml
end

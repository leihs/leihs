#!/usr/bin/env ruby
require 'yaml'
require 'pry'

def task_for_feature_file file_path, timeout = 200, strict = false
  name= file_path.match(/features\/(.*)\.feature/).captures.first
  exec = %{bundle exec cucumber -p default #{strict ? "--strict " : nil}"#{file_path}"}
  { "name" => name,
    "scripts" => {
      "cucumber" => {
          "timeout" => timeout,
          "body" => exec }
      }
  }
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

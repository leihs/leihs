#!/usr/bin/env ruby
require 'yaml'
require 'pry'

CI_AUTO_TRIALS = 3
CI_TIMEOUT = 300
CI_SCENARIOS_PER_TASK = 1

def task_hash(name, exec, timeout = nil)
  h = { "name" => name,
        "auto_trials" => CI_AUTO_TRIALS,
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
  exec = %{bundle exec cucumber -p default -f json -o log/cucumber_report.json #{strict ? "--strict " : nil}"#{file_path}"}
  task_hash(name, exec, timeout)
end

feature_files = Dir.glob("features/**/*.feature") - Dir.glob("features/personas/*.feature")
filepath = "./cider-ci/tasks/cucumber.yml"
File.open(filepath,"w") do |f|
  f.write(feature_files.map do |f|
    task_for_feature_file(f, CI_TIMEOUT)
  end.to_yaml)
end

default_browser = ENV['DEFAULT_BROWSER'] ? ENV['DEFAULT_BROWSER'] : [:firefox, :chrome].sample
filepath = "./cider-ci/tasks/cucumber_scenarios.yml"
File.open(filepath,"w") do |f|
  h1 = {}
  `egrep -R -n -B 1 "^\s*(Scenario|Szenario)" features/*`.split("--\n").map{|x| x.split("\n")}.each do |t, s|
    next if t =~ /@old-ui|@upcoming|@generating_personas/
    splitted_string = s.split(/:\s*(Scenario|Szenario)( Outline| Template|grundriss)?: /)
    k, v = splitted_string.first.split(':')
    h1[k] ||= []
    h1[k] << v
  end.compact

  h2 = []
  h1.map do |k,v|
    v.each_slice(CI_SCENARIOS_PER_TASK) do |lines|
      path = ([k] + lines).join(':')
      exec = "bundle exec cucumber -p default -f json -o log/cucumber_report.json %s DEFAULT_BROWSER=%s" % [path, default_browser]
      h2 << task_hash(path, exec, CI_TIMEOUT)
    end
  end

  f.write h2.to_yaml
end

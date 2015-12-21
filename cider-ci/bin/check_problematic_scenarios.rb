#!/usr/bin/env ruby

require 'yaml'

filepath = 'cider-ci/tasks/cucumber_leihs_problematic_scenarios.yml'
tasks = YAML.load File.open(filepath)

if `git ls-tree -r master --name-only | grep -c cucumber_leihs_problematic_scenarios.yml`.to_i == 1
  tasks_previous = YAML.load `git show master:#{filepath}`
  if tasks_previous['tasks'].size < tasks['tasks'].size
    exit false
  else
    exit true
  end
else
  exit true
end

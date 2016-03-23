#!/usr/bin/env ruby
require 'yaml'
require 'pry'

DEFAULT_BROWSER = ENV['DEFAULT_BROWSER'] ? ENV['DEFAULT_BROWSER'] : :firefox # [:firefox, :chrome].sample
CI_SCENARIOS_PER_TASK = (ENV['CI_SCENARIOS_PER_TASK'] || 1).to_i
STRICT_MODE = true
ENGINES = ['leihs_admin', 'procurement']

def task_hash(name, exec)
  h = { 'name' => name,
        'scripts' => {
            'test' => {
                'body' => exec
            }
        }
      }
  h
end

def task_for_feature_file file_path, _timeout = 200
  name= file_path.match(/features\/(.*)\.feature/).captures.first
  exec = %{DISPLAY=\":$XVNC_PORT\" bundle exec cucumber -p default #{STRICT_MODE ? "--strict " : nil}"#{file_path}"}
  task_hash(name, exec)
end

def create_feature_tasks(filepath, feature_files)
  File.open(filepath,'w') do |f|
    string = {'tasks' => feature_files.map do |f|
      task_for_feature_file(f)
    end}
    f.write(string.to_yaml)
  end
end

leihs_feature_files = \
  Dir.glob('features/**/*.feature') -
  Dir.glob('features/personas/*.feature') -
  Dir.glob('features/**/*.feature.disabled') -
  Dir.glob('engines/**/features/*')
filepath = 'cider-ci/tasks/cucumber_features.yml'
create_feature_tasks(filepath, leihs_feature_files)

ENGINES.each do |engine|
  engine_feature_files = Dir.glob("engines/#{engine}/features/**/*.feature")
  filepath = "cider-ci/tasks/cucumber_#{engine}_features.yml"
  create_feature_tasks(filepath, engine_feature_files)
end

EXCLUDE_TAGS = %w(@old-ui @upcoming @generating_personas @manual @problematic)

def create_scenario_tasks(filepath, feature_files_paths, test_with, tags = nil)
  File.open(filepath,'w') do |f|
    h1 = {}
    `egrep -R -n -B 1 -H "^\s*(Scenario|Szenario)" #{feature_files_paths}`
      .split("--\n")
      .map{|x| x.split("\n")}
      .each do |t, s|

      if tags and not t.match /#{tags.join("|")}/
        next
      end

      if not tags and t.match /#{EXCLUDE_TAGS.join("|")}/
        next
      end

      splitted_string = \
        s.split(/:\s*(Scenario|Szenario)( Outline| Template|grundriss)?: /)
      k, v = splitted_string.first.split(':')
      h1[k] ||= []
      h1[k] << v
    end.compact.sort.to_h

    h2 = []
    h1.map do |k,v|
      require = k =~ /^engines/ ? "-r engines/**/features" : nil
      v.each_slice(CI_SCENARIOS_PER_TASK) do |lines|
        path = ([k] + lines).join(':')
        case test_with
        when :cucumber
          exec = "DISPLAY=\":$XVNC_PORT\" bundle exec cucumber -p default %s #{STRICT_MODE ? "--strict " : nil}%s DEFAULT_BROWSER=%s" % [require, path, DEFAULT_BROWSER]
        when :rspec
          exec = "DISPLAY=\":$XVNC_PORT\" bundle exec rspec #{path}"
        else
          raise 'Undefined testing framework'
        end

        h2 << task_hash(path, exec)
      end
    end

    h3 = {'tasks' => h2}

    f.write h3.to_yaml
  end
end

filepath = 'cider-ci/tasks/cucumber_scenarios.yml'
leihs_feature_files_paths = 'features/*'
create_scenario_tasks(filepath, leihs_feature_files_paths, :cucumber)

# keep failing CI scenarios in a separate yml files (and job)
filepath = 'cider-ci/tasks/cucumber_problematic_scenarios.yml'
leihs_feature_files_paths = 'features/*'
create_scenario_tasks(filepath, leihs_feature_files_paths, :cucumber, ['@problematic'])

ENGINES.each do |engine|
  filepath = "cider-ci/tasks/cucumber_#{engine}_scenarios.yml"
  if engine == 'procurement'
    engine_feature_files_paths = "engines/#{engine}/spec/features/*.feature"
    create_scenario_tasks(filepath, engine_feature_files_paths, :rspec)
  else
    engine_feature_files_paths = "engines/#{engine}/**/*.feature"
    create_scenario_tasks(filepath, engine_feature_files_paths, :cucumber)
  end
end

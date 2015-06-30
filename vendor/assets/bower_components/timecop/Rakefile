# Build-related information:

TIMECOP_VERSION = '0.1.1'
project_root = File.expand_path(File.dirname(__FILE__))
output_path = File.join(project_root, "timecop-#{TIMECOP_VERSION}.js")
lib_dir = File.join(project_root, 'lib')

lib_files = [ 'Timecop', 'MockDate', 'TimeStackItem' ].map do |f|
  File.join(lib_dir, "#{f}.js")
end

# Tasks:

task :default => :build

desc "Delete all compiled version of the Timecop library"
task :clean do
  `rm timecop-*.js`
end

desc "compile, syntax-check, and test the Timecop library"
task :build => :test

desc "Run tests on the compiled Timecop library"
task :test => :jshint do
  sh "bundle exec jasmine-headless-webkit" do |ok, res|
    fail "Test failures" unless ok
  end
  puts "Tests passed"
end

namespace :jshint do
  task :require do
    sh "which jshint" do |ok, res|
      fail 'Cannot find jshint on $PATH' unless ok
    end
  end

  task :check => [ 'jshint:require', output_path ] do
    config_file = File.join(project_root, '.jshintrc')
    sh "jshint #{lib_files.join(' ')} --config #{config_file}" do |ok, res|
      fail 'JSHint found errors in source.' unless ok
    end

    sh "jshint #{output_path} --config #{config_file}" do |ok, res|
      fail 'JSHint found errors in compiled output.' unless ok
    end

    puts "JSHint checks passed"
  end
end

desc 'Run JSHint checks against Javascript source'
task :jshint => 'jshint:check'

desc "compile the files in lib/ to timecop-{version}.js"
file output_path => lib_files do
  template = File.read(File.join(lib_dir, 'BuildTemplate.js'))

  contents = lib_files.
              map { |f| File.read(f) }.
              join("\n\n")

  compiled = template.
              sub('{{ TIMECOP_VERSION }}', TIMECOP_VERSION).
              sub('{{ TIMECOP_LIBRARIES }}', contents)

  File.open(output_path, 'w') { |f| f.write(compiled) }

  puts("Wrote #{output_path}");
end

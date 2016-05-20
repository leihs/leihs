# encoding: utf-8
require 'rubygems'
require 'logger'
require 'yaml'
require 'fileutils'
require "./#{File.join(File.dirname(__FILE__), "lib", "semverly")}"


# Gotta set this before it gets overwritten
THIS_FILE = File.absolute_path(__FILE__)

require "./#{File.join(File.dirname(__FILE__), "lib", "semverly")}"

REPO_URL = 'https://github.com/leihs/leihs.git'
TARGET_DIR = File.join('/tmp', 'migrations')

# If no :ruby_version is given, we use this
DEFAULT_RUBY_VERSION = '2.1.1'

$logger = Logger.new(File.join('/tmp', 'validate_migrations.log'))
$logger.level = Logger::INFO

def write_database_config(target_path, mysql_version = 'mysql2')
  mysql_version ||= 'mysql2'
  database_config = { 'production' => { 'host' => 'localhost',
                                        'username' => 'jenkins',
                                        'password' => 'jenkins',
                                        'adapter' => mysql_version,
                                        'database' => 'leihs_migration_tests' } }

  config_file = File.open(target_path, 'w+')
  config_file.puts database_config.to_yaml
  config_file.close
end


def check_and_install_ruby(ruby_version)
  if system("bash -l -c 'rbenv versions | grep #{ruby_version}'") == false
    system("bash -l -c 'rbenv install #{ruby_version}'")
    system("bash -l -c 'rbenv shell #{ruby_version} && gem install bundler'")
  else
    log('debug', "Ruby #{ruby_version} was already installed, skipping installation.")
    if system("bash -l -c 'rbenv shell #{ruby_version} && bundle --version'") == false
       log('debug', "Installing bundler for #{ruby_version}")
      system("bash -l -c 'rbenv shell #{ruby_version} && gem install bundler'")
    else
      log('debug', "Ruby #{ruby_version} already has Bundler, skipping that.")
    end
  end
end

def wrap(command, ruby_version)
  check_and_install_ruby(ruby_version)
  prefix = "bash -l -c 'rbenv shell #{ruby_version} && export RAILS_ENV=production && "
  postfix = "'"
  command = "#{prefix}#{command}#{postfix}"
  log('debug', "Assembled command: #{command}")
  return command
end

def switch_to_tag(tag)
  Dir.chdir(TARGET_DIR)
  changed = `git status | egrep "(database.yml|schema.rb)"`
  if changed != ''
    system('git checkout -- config/database.yml') if File.exist?(File.join('.', 'config', 'database.yml'))
    system('git checkout -- db/schema.rb') if File.exist?(File.join('.', 'db', 'schema.rb'))
  end
  if system("git checkout #{tag}")
    log('info', "Switched repository to tag #{tag}", true)
  end
  mysql2 = `grep mysql2 Gemfile`
  mysql_version = 'mysql' if mysql2 == ''

  database_config_file_path = File.join('.', 'config', 'database.yml')
  write_database_config(database_config_file_path, mysql_version)
end

def log(log_level = 'info', message = '', stdout = false)
  $logger.send(log_level, message)
  puts message if stdout == true
end

def reset_installation(leihs_version)
  errors = 0
  ruby_versions_for(leihs_version).each do |ruby_version|
    switch_to_tag(leihs_version)
    system(wrap("bundle install --deployment --without test development cucumber --path=#{TARGET_DIR}/bundle", ruby_version))
    system(wrap('bundle exec rake db:drop db:create db:migrate', ruby_version ))
    if $?.exitstatus != 0
      errors += 1
    else
      log('info', "Reset the database for #{leihs_version} using Ruby #{ruby_version}.")
    end
  end

  if errors > 0
    log('error', "Error while resetting version #{leihs_version} using Ruby #{ruby_version}.")
    return false
  else
    return true
  end
end

def seed_migration_data(leihs_version)
  if leihs_version.to_f > 2.9
    log('error', "Can't seed data for leihs version #{leihs_version}. The seed data file matches only leihs 2.9, not leihs 3.0 or higher.")
    return false
  else
    ruby_version = ruby_versions_for(leihs_version).first
    output = ''
    output = `#{wrap("bundle exec ./script/runner #{File.join(TARGET_DIR, "data.rb")}", ruby_version)}`
    if $?.exitstatus != 0
      log('error', "Error during migration data seeding: #{output.strip}.")
      return false
    else
      log('info', "Data seeding results: #{output.strip}.")
      return true
    end
  end
end

def attempt_migration(from: nil, to: nil)

  if (to == nil)
    raise 'Need to give a version to migrate to.'
  end

  if (from and to)
    if skip_combination?(from, to)
      log('info', "Skipping #{from} to #{to} because we know it won't work.")
      return true
    end
  end

  Dir.chdir(TARGET_DIR)
  log('debug', "Trying migrations inside #{TARGET_DIR}")
  if from
    if !reset_installation(from)
      return false
    end
  end
  switch_to_tag(to)
  ruby_versions_for(to).each do |to_ruby_version|
    system(wrap("bundle install --deployment --without test development cucumber --path=#{TARGET_DIR}/bundle", to_ruby_version))
    output = `#{wrap('bundle exec rake db:migrate', to_ruby_version)}`

    if $?.exitstatus == 0
      return true
    else
      log('error', "Error during migration attempt from #{from} to #{to} using Ruby #{to_ruby_version}: #{output}")
      return false
    end
  end
end

def setup_target_directory
  if File.exist?(TARGET_DIR)
    Dir.chdir(TARGET_DIR)
    git = system('git status')
    if git
      system('git fetch')
    else
      system("rm -rf #{TARGET_DIR}")
      system("git clone #{REPO_URL} #{TARGET_DIR}")
    end
  else
    system("git clone #{REPO_URL} #{TARGET_DIR}")
  end
  # Gotta do this before __FILE__ gets weirdly overwritten
  FileUtils.copy(File.join(File.dirname(THIS_FILE), 'validate_migrations_data.rb'), File.join(TARGET_DIR, 'data.rb'))

end


def get_versions(higher_than = nil)
  Dir.chdir(TARGET_DIR)
  output = `git tag --list`
  if higher_than
    versions = output.split("\n").map { |s| 
      SemVer.parse(s) 
    }.compact.sort.select{ |v| 
      v > SemVer.parse(higher_than)
    }.map(&:to_s)
  else
    versions = output.split("\n").map { |s| SemVer.parse(s) }.compact.sort.map(&:to_s)
  end

  # Filter out alphas and betas and rcs
  versions = versions.select{ |v|
    v if v.match(/(beta|alpha|rc)/).nil?
  }
  return versions
end


# Which Ruby should be used/tested for migrating *to* version 'version'?
def ruby_versions_for(version)
  version_map = {
    '2.9.13' => ['1.8.7-p375'],
    '2.9.14' => ['1.8.7-p375'],
    '3.0.0' => ['1.9.3-p545', '2.1.1'],
    '3.0.1' => ['1.9.3-p545', '2.1.1'],
    '3.0.2' => ['1.9.3-p545', '2.1.1'],
    '3.0.3' => ['1.9.3-p545', '2.1.1'],
    '3.0.4' => ['1.9.3-p545', '2.1.1'],
    '3.1.0' => ['1.9.3-p545', '2.1.1'],
    '3.2.0' => ['1.9.3-p545', '2.1.1'],
    '3.3.0' => ['1.9.3-p545', '2.1.1'],
    '3.3.1' => ['1.9.3-p545', '2.1.1'],
    '3.3.2' => ['1.9.3-p545', '2.1.1'],
    '3.4.0' => ['1.9.3-p545', '2.1.1'],
    '3.5.0' => ['1.9.3-p545', '2.1.1'],
    '3.6.0' => ['1.9.3-p545', '2.1.1'],
    '3.6.1' => ['1.9.3-p545', '2.1.1'],
    '3.7.0' => ['1.9.3-p545', '2.1.1']
  }

  if version_map[version]
    return version_map[version]
  else
    return [DEFAULT_RUBY_VERSION]
  end
end


# These combinations will never work, so we list them here
def skip_combination?(from, to)
  skip = false

  # You can only go from 3.5.0 onwards if you first migrate to 3.5.0
  if (SemVer.parse(from) < SemVer.parse('3.5.0') and
      SemVer.parse(to) > SemVer.parse('3.5.0'))
    skip = true
  end
  return skip
end

def attempt_direct_migrations
  error_messages = []
  error_count = 0

  versions = get_versions('2.9.12')
  versions = versions.select{|v| v if v == ARGV[0]} if ARGV[0]

  # --- Direct migration
  # This migrates only from one version directly to the next, not doing
  # any intermediate migrations but resetting the data on every pair. e.g.
  # when it runs the 3.0.0 to 3.0.1 migration, it will reset the database using
  # 3.0.0, it will not upgrade through 2.9.13, 2.9.14 to 3.0.0 first.
  versions.each do |version|
    target_versions = determine_target_versions(version)

    log('info', "---> Will try to migrate from #{version} to #{target_versions.join(", ")} directly, in pairs.")
    target_versions.each do |target_version|
      log('info', "Attempting migration from #{version} to #{target_version}.")
      if attempt_migration(from: version, to: target_version) == true
        log('info', "Migration (direct) from #{version} to #{target_version} was successful.")
      else
        error_message = "Migration (direct) from #{version} to #{target_version} has failed."
        error_messages << error_message
        log('error', error_message)
        error_count += 1
      end
    end
  end

  if error_count == 0
    return 0
  else
    log('error', 'Migrations with errors:', true)
    log('error', error_messages.join("\n"), true)
    return error_count
  end
end

def determine_target_versions(minimum_version, mode = :direct)
  target_versions = get_versions(minimum_version)
  if mode == :direct
    target_versions = target_versions.select{|v| v if v == ARGV[1]} if ARGV[1]
  # Get all the valid versions in between minimum version and ARGV[1]
  elsif mode == :sequential
    target_versions = target_versions.select{|v| v if SemVer.parse(v) <= SemVer.parse(ARGV[1])} if ARGV[1]
  end
  target_versions
end

def attempt_sequential_migrations
  error_messages = []
  error_count = 0

  version = get_versions('2.9.12').first
  version = ARGV[0] if ARGV[0]

  target_versions = determine_target_versions(version, :sequential)

  $logger.info "---> Will try to migrate from #{version} through to #{target_versions.join(", ")} each in sequence, keeping the data between migrations."
  # This is to reset the data to some baseline that works
  if reset_installation(version) && seed_migration_data(version) == true
    target_versions.each do |target_version|
      log('info', "Attempting migration to #{target_version}, keeping data from previous version.")
      if attempt_migration(to: target_version) == true
        log('info', "Migration (sequential) to #{target_version} was successful.")
      else
        error_message = "Migration (sequential) to #{target_version} has failed."
        error_messages << error_message
        log('error', error_message)
        error_count += 1
      end
    end
  else
    error_message = "Initial setup for sequential migration from #{version} to #{target_version} failed."
    error_messages << error_message
    $logger.error error_message
    error_count += 1
  end

  if error_count == 0
    return 0
  else
    log('error', 'Migrations with errors:', true)
    log('error', error_messages.join("\n"), true)
    return error_count
  end
end


errors = 0
setup_target_directory
errors += attempt_direct_migrations
errors += attempt_sequential_migrations
if errors > 0
  log('error', 'Migration test had some errors. See /tmp/validate_migrations.log for details.', true)
  exit 1
else
  log('info', 'All migrations successful.', true)
  exit 0
end

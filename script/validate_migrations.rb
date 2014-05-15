# encoding: utf-8
require 'rubygems'
#require 'pry'
require 'logger'
require 'yaml'
require "./#{File.join(File.dirname(__FILE__), "lib", "semverly")}"

REPO_URL = "https://github.com/zhdk/leihs.git"
TARGET_DIR = File.join("/tmp", "migrations")

# If no :ruby_version is given, we use this
DEFAULT_RUBY_VERSION = '2.1.1'

$logger = Logger.new(File.join("/tmp", "validate_migrations.log"))
$logger.level = Logger::INFO

def write_database_config(target_path, mysql_version = "mysql2")
  mysql_version ||= "mysql2"
  database_config = { "production" => { "host" => "localhost",
                                        "username" => "jenkins",
                                        "password" => "jenkins",
                                        "adapter" => mysql_version,
                                        "database" => "leihs_migration_tests" } }

  config_file = File.open(target_path, "w+")
  config_file.puts database_config.to_yaml
  config_file.close
end


def check_and_install_ruby(ruby_version)
  if system("bash -l -c 'rbenv version #{ruby_version}'") == false
    system("bash -l -c 'rbenv install #{ruby_version}'")
    system("bash -l -c 'rbenv shell #{ruby_version} && gem install bundler'")
  else
    $logger.debug "Ruby #{ruby_version} was already installed, skipping installation."
    if system("bash -l -c 'rbenv shell #{ruby_version} && bundle --version'") == false
       $logger.debug "Installing bundler for #{ruby_version}"
      system("bash -l -c 'rbenv shell #{ruby_version} && gem install bundler'")
    else
      $logger.debug "Ruby #{ruby_version} already has Bundler, skipping that."
    end
  end
end

def wrap(command, ruby_version)
  check_and_install_ruby(ruby_version)
  prefix = "bash -l -c 'rbenv shell #{ruby_version} && cd #{TARGET_DIR} && export RAILS_ENV=production && "
  postfix = "'"
  command = "#{prefix}#{command}#{postfix}"
  return command
end

def switch_to_tag(tag)
  Dir.chdir(TARGET_DIR)
  changed = `git status | egrep "(database.yml|schema.rb)"`
  if changed != ""
    system("git checkout -- config/database.yml") if File.exist?(File.join(".", "config", "database.yml"))
    system("git checkout -- db/schema.rb") if File.exist?(File.join(".", "db", "schema.rb"))
  end
  system("git checkout #{tag}")
  mysql2 = `grep mysql2 Gemfile`
  mysql_version = "mysql" if mysql2 == ""

  database_config_file_path = File.join(".", "config", "database.yml")
  write_database_config(database_config_file_path, mysql_version)
end

def attempt_migration(ruby_version: DEFAULT_RUBY_VERSION, from: nil, to: nil)

  if (from == nil or to == nil)
    raise "Need to give both a from and a to version"
  end

  Dir.chdir(TARGET_DIR)
  $logger.debug "Trying migrations inside #{TARGET_DIR}"
  switch_to_tag(from)
  system(wrap("bundle install --deployment --without test development cucumber --path=#{TARGET_DIR}/bundle", ruby_version))
  system(wrap("bundle exec rake db:drop db:create db:migrate", ruby_version )) or return false

  switch_to_tag(to)
  system(wrap("bundle install --deployment --without test development cucumber --path=#{TARGET_DIR}/bundle", ruby_version))
  output = `#{system(wrap("bundle exec rake db:migrate", ruby_version))}`

  if $?.exitstatus == 0
    return true
  else
    $logger.error "Error during migration attempt to #{to}: #{output}"
    return false
  end
end

def setup_target_directory
  if File.exist?(TARGET_DIR)
    Dir.chdir(TARGET_DIR)
    git = system("git status")
    if git
      system("git fetch")
    else
      system("rm -rf #{TARGET_DIR}")
      system("git clone #{REPO_URL} #{TARGET_DIR}")
    end
  else
    system("git clone #{REPO_URL} #{TARGET_DIR}")
  end
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


def lookup_ruby_versions_for(version)
  version_map = {
    "2.9.13" => ["1.8.7-p375"],
    "2.9.14" => ["1.8.7-p375"],
    "3.0.0" => ["1.9.3-p545", "2.1.1"],
    "3.0.1" => ["1.9.3-p545", "2.1.1"],
    "3.0.2" => ["1.9.3-p545", "2.1.1"],
    "3.0.3" => ["1.9.3-p545", "2.1.1"],
    "3.0.4" => ["1.9.3-p545", "2.1.1"],
    "3.1.0" => ["1.9.3-p545", "2.1.1"],
    "3.2.0" => ["1.9.3-p545", "2.1.1"],
    "3.3.0" => ["1.9.3-p545", "2.1.1"],
    "3.3.1" => ["1.9.3-p545", "2.1.1"],
    "3.3.2" => ["1.9.3-p545", "2.1.1"],
    "3.4.0" => ["1.9.3-p545", "2.1.1"],
    "3.5.0" => ["1.9.3-p545", "2.1.1"]
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
  if (SemVer.parse(from) < SemVer.parse("3.5.0") and
      SemVer.parse(to) > SemVer.parse("3.5.0"))
    skip = true
  end
  return skip
end

def attempt_migrations
  error_messages = []
  error_count = 0

  versions = get_versions("2.9.12")

  versions.each do |version|
    # Get all versions higher than the current one
    target_versions = get_versions(version)
    $logger.info "---> Will try to migrate from #{version} to #{target_versions.join(", ")}"
    target_versions.each do |target_version|
      if skip_combination?(version, target_version)
        $logger.info "Skipping #{version} to #{target_version} because we know it won't work."
        next
      end
      ruby_versions = lookup_ruby_versions_for(target_version)
      ruby_versions.each do |ruby_version|
        $logger.info "Attempting migration from #{version} to #{target_version} using Ruby #{ruby_version}."
        if attempt_migration(:from => version, :to => target_version, :ruby_version => ruby_version) == true
          $logger.info "Migration from #{version} to #{target_version} using Ruby #{ruby_version} was successful."
        else
          error_message = "Migration from #{version} to #{target_version} using Ruby #{ruby_version} has failed."
          error_messages << error_message
          $logger.error error_message
          error_count += 1
        end
      end
    end
  end

  if error_count == 0
    exit 0
  else
    $logger.error "Migrations with errors:"
    $logger.error error_messages.join("\n")

    puts "Migrations with errors:"
    puts error_messages.join("\n")
    exit 1
  end
end

setup_target_directory
attempt_migrations

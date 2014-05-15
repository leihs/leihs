require 'rubygems'
require 'pry'

REPO_URL = "https://github.com/zhdk/leihs.git"
TARGET_DIR = File.join("/tmp", "migrations")
# If no :ruby_version is given, we use this
DEFAULT_RUBY_VERSION = '2.1.1'

SUPPORTED_MIGRATIONS = [

                         { :ruby_version => '1.9.3-p545',
                           :from => '2.9.14',
                           :to => '3.0.1' },

                         { :ruby_version => '1.9.3-p545',
                           :from => '3.0.1',
                           :to => '3.0.2' },

                         { :from => '3.0.2',
                           :to => '3.0.3' },

                         { :from => '3.0.3',
                           :to => '3.0.4' },

                         { :from => '3.0.4',
                           :to => '3.1.0' },

                         { :from => '3.1.0',
                           :to => '3.2.0' },

                         { :from => '3.2.0',
                           :to => '3.2.1' },

                         { :from => '3.2.1',
                           :to => '3.3.0' },

                         { :from => '3.3.0',
                           :to => '3.3.1' },

                         { :from => '3.3.1',
                           :to => '3.3.2' },

                         { :from => '3.3.2',
                           :to => '3.4.0' },

                         { :from => '3.4.0',
                           :to => '3.5.0' },

                         { :from => '3.5.0',
                           :to => '3.5.1' },

                         { :from => '3.5.1',
                           :to => '3.6.0' },

                         { :from => '3.6.0',
                           :to => '3.6.1' }
]


def write_database_config(target_path)

  database_config = { "production" => { "host" => "localhost",
                                        "username" => "jenkins",
                                        "password" => "jenkins",
                                        "adapter" => "mysql2",
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
    puts "Ruby #{ruby_version} was already installed, skipping installation."
    if system("bash -l -c 'rbenv shell #{ruby_version} && bundle --version'") == false
      puts "Installing bundler for #{ruby_version}"
      system("bash -l -c 'rbenv shell #{ruby_version} && gem install bundler'")
    else
      puts "Ruby #{ruby_version} already has Bundler, skipping that."
    end
  end
end

def wrap(command, ruby_version)
  puts "Using #{ruby_version}"
  check_and_install_ruby(ruby_version)
  prefix = "bash -l -c 'rbenv shell #{ruby_version} && cd #{TARGET_DIR} && export RAILS_ENV=production && "
  postfix = "'"
  command = "#{prefix}#{command}#{postfix}"
  #puts "Prepared command: #{command}"
  return command
end

def switch_to_tag(tag)
  Dir.chdir(TARGET_DIR) do
    changed = `git status | egrep "(database.yml|schema.rb)"`
    if changed != ""
      system("git checkout -- config/database.yml") if File.exist?(File.join(".", "config", "database.yml"))
      system("git checkout -- db/schema.rb") if File.exist?(File.join(".", "db", "schema.rb"))
    end
    system("git checkout #{tag}")
    database_config_file_path = File.join(".", "config", "database.yml")
    write_database_config(database_config_file_path)
  end
end

def attempt_migration(ruby_version: DEFAULT_RUBY_VERSION, from: nil, to: nil)

  if (from == nil or to == nil)
    raise "Need to give both a from and a to version"
  end

  Dir.chdir(TARGET_DIR) do
    puts "Trying migrations inside #{TARGET_DIR}"
    switch_to_tag(from)
    system(wrap("bundle install --deployment --without test development --path=#{TARGET_DIR}/bundle", ruby_version))
    system(wrap("bundle exec rake db:drop db:create db:migrate", ruby_version ))

    switch_to_tag(to)
    system(wrap("bundle install --deployment --without test development --path=#{TARGET_DIR}/bundle", ruby_version))
    output = `#{system(wrap("bundle exec rake db:migrate", ruby_version))}`
  end

  if $?.exitstatus == 0
    return true
  else
    puts "Error during migration attempt to #{to}: #{output}"
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


def attempt_migrations
  error_messages = []
  error_count = 0

  SUPPORTED_MIGRATIONS.each do |mig|
    ruby_version = DEFAULT_RUBY_VERSION
    ruby_version = mig[:ruby_version] if mig[:ruby_version]

    if attempt_migration(:from => mig[:from], :to => mig[:to], :ruby_version => ruby_version) == true
      puts "Migration from #{mig[:from]} to #{mig[:to]} using Ruby #{ruby_version} was successful."
    else
      error_message = "Migration from #{mig[:from]} to #{mig[:to]} using Ruby #{ruby_version} has failed."
      error_messages << error_message
      puts error_message
      error_count += 1
    end
  end

  if error_count == 0
    exit 0
  else
    puts "Migrations with errors:"
    puts error_messages.join("\n")
    exit 1
  end
end

setup_target_directory
attempt_migrations

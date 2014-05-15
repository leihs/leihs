require 'rubygems'
require 'pry'

REPO_URL = "https://github.com/zhdk/leihs.git"

TARGET_DIR = File.join("/tmp", "migrations")

# If no :ruby_version is given, we use this
DEFAULT_RUBY_VERSION = '2.1.1'

SUPPORTED_MIGRATIONS = [
                         { :ruby_version => '1.8.7-p375',
                           :from => '2.9.9',
                           :to => '3.0.1' },

                         { :ruby_version => '1.9.3-p545',
                           :from => '3.0.1',
                           :to => '3.0.2' },

                         { :from => '3.0.2',
                           :to => '3.0.3' }
]

def check_and_install_ruby(ruby_version)
  if system("bash -l -c 'rbenv version #{ruby_version}'") == false
    system("bash -l -c 'rbenv install #{ruby_version}'")
    system("bash -l -c 'rbenv shell #{ruby_version} && gem install bundler'")
  else
    if system("bash -l -c 'rbenv shell #{ruby_version} && bundle --version'") == false
      puts "Installing bundler for #{ruby_version}"
      system("bash -l -c 'rbenv shell #{ruby_version} && gem install bundler'")
    else
      puts "Ruby #{ruby_version} already has Bundler, skipping that."
    end
    puts "Ruby #{ruby_version} was already installed, skipping installation."
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

def attempt_migration(ruby_version: DEFAULT_RUBY_VERSION, from: nil, to: nil)

  if (from == nil or to == nil)
    raise "Need to give both a from and a to version"
  end

  Dir.chdir(TARGET_DIR) do
    puts "Trying migrations inside #{TARGET_DIR}"
    system("git checkout #{from}") or return false

    system(wrap("bundle install --deployment --without test development --path=#{TARGET_DIR}/bundle", ruby_version)) or return false
    system(wrap("bundle exec rake db:migrate", ruby_version )) or return false
    system("git checkout #{to}") or return false

    output = `#{system("bundle exec rake db:migrate", ruby_version)}`
  end

  if $?.exitstatus == 0
    return true
  else
    puts "Error during migration attempt: #{output}"
    return false
  end
end


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

error_messages = []
error_count = 0

SUPPORTED_MIGRATIONS.each do |mig|
  ruby_version = DEFAULT_RUBY_VERSION
  ruby_version = mig[:ruby_version] if mig[:ruby_version]

  if attempt_migration(:from => mig[:from], :to => mig[:to], :ruby_version => ruby_version) == true
    puts "Migration from #{mig[:from]} to #{mig[:to]} using Ruby #{ruby_version} was successful."
  else
    error_message = "Migration from #{mig[:from]} to #{mig[:to]} using Ruby #{ruby_version} was failed."
    error_messages << error_message
    puts error_message
    error_count += 1
  end
end

if error_count == 0
  exit 0
else
  puts "Errored migrations:"
  error_messages.each do |em|
    puts em + "\n"
  end
  exit 1
end

require 'rubygems'
require 'pry'

# This is a spec file meant to run with rspec: bundle exec rspec scripts/validate_migrations.rb
#
# Why rspec? So we can use "should" and get nice output.
# Do *not* copy this into the spec/ directory! It is something completely separate
# and it messes up the currently cloned git repository.

RSpec.configure do |config|
  config.mock_with :rspec
end

REPO_URL = "https://github.com/zhdk/leihs.git"

TARGET_DIR = File.join(File.dirname(__FILE__), "migrations")

# If no :ruby_version is given, we use this
DEFAULT_RUBY_VERSION = '2.1.1'

SUPPORTED_MIGRATIONS = [
                         { :ruby_version => '1.9.3-p545',
                           :from => '2.9.9',
                           :to => '3.0.1' },

                         { :from => '3.0.1',
                           :to => '3.0.2' },

                         { :from => '3.0.2',
                           :to => '3.0.3' }
]


def wrap(command, ruby_version)
  puts "Using #{ruby_version}"
  prefix = "bash -l -c 'rbenv shell #{ruby_version} && RAILS_ENV=production "
  postfix = "'"
  return "#{prefix}#{command}#{postfix}"
end

def attempt_migration(ruby_version: DEFAULT_RUBY_VERSION, from: nil, to: nil)

  if (from == nil or to == nil)
    raise "Need to give both a from and a to version"
  end

  Dir.chdir(TARGET_DIR)
  puts "Trying migrations inside #{TARGET_DIR}"
  system("git checkout #{from}").should == true
  system(wrap("bundle install --deployment --without test development", ruby_version)).should == true
  system(wrap("bundle exec rake db:migrate", ruby_version )).should == true
  system("git checkout #{to}").should == true
  system(wrap("bundle exec rake db:migrate", ruby_version)).should == true

  if $?.exitstatus == 0
    return true
  else
    puts "Error during migration attempt: #{output}"
    return false
  end
end


describe "migration" do

  before(:all) do
    system("rm -rf #{TARGET_DIR}")
    system("git clone #{REPO_URL} #{TARGET_DIR}")
  end

  it "should migrate from any supported version to another" do
    SUPPORTED_MIGRATIONS.each do |mig|
      ruby_version = DEFAULT_RUBY_VERSION
      ruby_version = mig[:ruby_version] if mig[:ruby_version]
      attempt_migration(:from => mig[:from], :to => mig[:to], :ruby_version => ruby_version).should == true
    end
  end
end

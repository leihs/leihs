#!/usr/bin/env ruby

# Exit codes:
# 0   Test run successful (even with reruns)
# 1   Unspecified error
# 4   No profile given
# 8   Gettext isn't installed
# 16  Gettext files did not validate

# TODO: Use Open4 to continuously flush STDOUT output from the cucumber
# processes.

require 'rubygems'
require 'fileutils'
require 'pry'


PROFILES = ['default', 'headless', 'nojs']

def die(exit_code, error)
  puts "Error: #{error}"
  exit exit_code
end

def gettext_installed?
  `which msgcat >> /dev/null`
  if $?.exitstatus == 0
    return true
  else
    return false
  end
end


def gettext_file_valid?(file)
  `msgcat #{file} >> /dev/null`
  if $?.exitstatus == 0
    return true
  else
    return false
  end
end

def gettext_files_valid?
  files = ["locale/leihs.pot"]
  files += Dir.glob("locale/**/leihs.po")
  files.each do |file|
    return false unless gettext_file_valid?(file)
  end
  return true
end

def rerun(maximum = 3, run_count = 0)
  while run_count <= maximum
    if File.exists?("tmp/rererun.txt")
      FileUtils.mv("tmp/rererun.txt", "tmp/rerun.txt")
    end
    if (File.exists?("tmp/rerun.txt") && File.size("tmp/rerun.txt") > 0)
      puts "Rerun necessary."
      puts `bundle exec cucumber -p rerun`
      run_count += 1
      if $?.exitstatus != 0
        rerun(maximum, run_count)
      else
        die(0, "All went well after rerunning.")
      end
    end
  end
end


# Do we know what we're doing?

profile = ARGV[0]
if PROFILES.include?(profile) == false
  die(4, "Please specify a valid profile, one of #{PROFILES.join(", ")}.")
end

# Prerequisites for testing

if not gettext_installed?
  die(8, "Gettext isn't installed. Make sure you have gettext and msgcat and msgmerge are in your PATH.")
end

if not gettext_files_valid?
  die(16, "The gettext files did not validate.")
end

# Testing proper

puts "Prerequisites for running the tests are met, starting Cucumber..."
FileUtils.rm_f(["tmp/rerun.txt", "tmp/rererun.txt"])
puts `bundle exec cucumber -p #{profile}`

# Rerun for failures, up to n times

if $?.exit_status != 0
  rerun(4)
else
  die(0, "All went well on the very first run.")
end

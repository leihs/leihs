#!/usr/bin/env ruby

require 'rubygems'
require 'fileutils'
require 'pry'

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

if not gettext_installed?
  die(8, "Gettext isn't installed. Make sure you have gettext and msgcat and msgmerge are in your PATH.")
end

if not gettext_files_valid?
  die(16, "The gettext files did not validate.")
end

exit 0

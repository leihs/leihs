#!/usr/bin/env ruby

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  # fixed versions avoid frequent checks and reinstalls
  gem 'pry', '= 0.14.2'
  gem 'activesupport', '~> 7' 
end

require 'active_support/all'


############## options ########################################################
require 'optparse'

options = {skip_fetch: false}
OptionParser.new do |parser|
  parser.banner = "git-check-ahead-of-origin-master [options]"
  parser.on("-k", "--skip-fetch", "Skip fetching origin/master") do |s|
    options[:skip_fetch] = s
  end
  parser.on("-h", "--help") do 
    puts parser 
    exit 0
  end
end.parse!


############## main ###########################################################


ALL_REPOS= `git submodule status --recursive`.split("\n").map{|sub| sub.strip.split(/\s+/).map(&:strip)}.map(&:second).append(".").sort()
BEHIND_AHEAD= ALL_REPOS.map { |repo| 
  `git -C #{repo} fetch origin master` unless options[:skip_fetch]
  [repo, `git -C #{repo} rev-list --left-right --count origin/master...HEAD` \
    .split(/\s/).map(&:to_i)].flatten
}

$exit_val = 0

def main 
  print("###############################################################################\n")
  print("behind ahead repo\n")
  BEHIND_AHEAD.each do |repo, behind, ahead|
    printf("   %3d   %3d %s\n", behind, ahead, repo )
    $exit_val += (behind == 0 ? 0 : 1)
  end
  print("behind ahead repo\n")
  print("###############################################################################\n")
  if $exit_val == 0
    puts "All OK"
  else
    puts "ERROR: no HEAD must be behind master <=> behind values must all be zero"
  end
  exit $exit_val
end

main()

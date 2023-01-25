#!/usr/bin/env ruby

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  # fixed versions avoid frequent checks and reinstalls
  gem 'pry', '= 0.14.2'
  gem 'activesupport', '= 6.1.7' 
end

require 'active_support/all'

ALL_REPOS= `git submodule status --recursive`.split("\n").map{|sub| sub.strip.split(/\s+/).map(&:strip)}.map(&:second).append(".").sort()

BEHIND_AHEAD= ALL_REPOS.map { |repo| 
  `git -C #{repo} fetch origin master`
  [repo, `git -C #{repo} rev-list --left-right --count origin/master...HEAD` \
    .split(/\s/).map(&:to_i)].flatten
}

$exit_val = 0

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



SHARED_SUBS_MATCHERS= 
  {database: /database$/,
   legacy: /legacy$|legacy-api$/,
   ui: /leihs-ui$/,
   clj: /shared-clj$/}

SHARED_SUBS = SHARED_SUBS_MATCHERS.map{ |key,match|
  [key, ALL_SUBS.filter{|sub| sub.second[match]}]
}.to_h

# print
SHARED_SUBS.each do |name, subs|
  printf("SUBMODULE %s\n", name)
  subs.each do | id,sub |
    printf(" %s %s\n",id, sub)
  end
end

puts ""

$exit_val = 0

# check
SHARED_SUBS.each do |name, subs|
  ids = Set.new(subs.map(&:first))
  if ids.size != 1 
    printf("ERROR %s : %s \n", name, ids.join(", ")) 
    $exit_val += 1
  end
end

puts "ALL OK" if $exit_val == 0 

exit $exit_val

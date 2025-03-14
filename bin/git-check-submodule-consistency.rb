#!/usr/bin/env ruby

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  # fixed versions avoid frequent checks and reinstalls
  gem 'pry', '= 0.14.2'
  gem 'activesupport', '~> 7' 
end

require 'active_support/all'

ALL_SUBS = `git submodule status --recursive`.split("\n").map{|sub| sub.strip.split(/\s+/).map(&:strip)}

SHARED_SUBS_MATCHERS= 
  {database: /database$/,
   legacy: /legacy$|legacy-api$/,
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

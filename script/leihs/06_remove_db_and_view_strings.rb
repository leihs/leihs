#!/usr/bin/ruby
#
# remove view and db strings
#
# input:
# 
# "2010-08-11 02:37:4",GET,21,View: 0,DB: 3,302,http://leihs.zhdk.ch/
#
# output:
#
# "2010-08-11 02:37:4",GET,21,0,3,302,http://leihs.zhdk.ch/

datapoints=100

while( line = gets ) do
  print line.sub(/View: /,'').sub(/DB: /,'')
end

#!/usr/bin/ruby
#
# pick relevant columns only
#
# input:
# 
# "2010-08-11 02:37:4",GET,21,0,3,302,http://leihs.zhdk.ch/
#
# output:
#
# "2010-08-11 02:37:4",21,0,3

datapoints=100

while( line = gets ) do
  date,foo1,total,view,db,foo2 = line.split(/,/)
  puts( date + ',' + total + ',' + view + ',' + db )
end

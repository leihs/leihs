#!/usr/bin/ruby
#
# since staroffice can't manage more than 65k lines
# we calculate means and reduce the set accordingly
#
# input:
# 
# "2010-08-11 02:37:4",21,0,3
# "2010-08-11 02:38:0",20,0,0
# "2010-08-11 02:38:1",9,0,3
# "2010-08-11 02:38:2",12,0,0
# "2010-08-11 06:37:3",20,0,3
# "2010-08-11 07:10:3",21,0,3
# "2010-08-11 07:10:3",22,0,0
# "2010-08-11 07:10:3",8,0,2
# "2010-08-11 07:10:3",12,0,0
# "2010-08-11 07:10:4",1650,0,58
#
# output:
#
# "2010-08-11 09:20:04",350,50,300
# "2010-08-11 10:17:22",200,40,160

datapoints=100
l=0
rails_total_total = 0
view_total        = 0
db_total          = 0

while( line = gets ) do
  date,rails_total,view,db = line.split(/,/)

  if l % 100 == 0
    puts date                                + ',' +
         (rails_total_total/datapoints).to_s + ',' +
	 (view_total/datapoints).to_s        + ',' + 
	 (db_total/datapoints).to_s

    rails_total_total = 0
    view_total        = 0
    db_total          = 0
  end

  rails_total_total += rails_total.to_i
  view_total        += view.to_i
  db_total          += db.to_i

  l += 1
end

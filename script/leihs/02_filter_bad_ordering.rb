#!/usr/bin/ruby
#
# input:
# Processing FrontendController#index (for 174.129.174.183 at 2010-08-11 02:37:47) [GET]
# Processing FrontendController#index (for 174.129.174.183 at 2010-08-11 02:37:47) [GET]
# Completed in 21ms (DB: 3) | 302 Found [http://leihs.zhdk.ch/]
#
# output:
# Processing FrontendController#index (for 174.129.174.183 at 2010-08-11 02:37:47) [GET]
# Completed in 21ms (DB: 3) | 302 Found [http://leihs.zhdk.ch/]

first = ''
second = ''
while( line = gets ) do
  if first =~ /^Processing/ and second =~ /^Completed/
    print first
    print second
    # get next two lines
    first = line
    second = gets
  else
    STDERR.print "S02: threw away #{first}"
    first = second
    second = line
  end
end


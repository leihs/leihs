#!/usr/bin/ruby
#
# input:
# Processing FrontendController#index (for 174.129.174.183 at 2010-08-11 02:37:47) [GET]
# Completed in 21ms (DB: 3) | 302 Found [http://leihs.zhdk.ch/]
#
# output:
# Processing FrontendController#index (for 174.129.174.183 at 2010-08-11 02:37:47) [GET]
# Completed in 21ms (DB: 3) | 302 Found [http://leihs.zhdk.ch/]

while( line = gets) do
  first  = line.chomp
  second = gets.chomp
  if first =~ /^Processing/ and second =~ /^Completed/
    puts( first + ',' + second)
  else
    STDERR.puts "S03: Error: #{first}"
    STDERR.puts "S03: Error: #{second}"
  end
end

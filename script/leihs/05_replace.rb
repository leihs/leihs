#!/usr/bin/ruby
#
# input:
# Processing FrontendController#index (for 174.129.174.183 at 2010-08-11 02:37:47) [GET],Completed in 21ms (View: 18, DB: 3) | 302 Found [http://leihs.zhdk.ch/]
#
# output:
# "2010-08-11 02:37:47",GET,21,View: 18,DB: 3,302,http://leihs.zhdk.ch/

class Line
  def initialize(line)
    @line     = line
    @original = @line.clone
    @continue = true
  end

  def replace(regex, by, step)
    if @continue
  	  if @line =~ regex
        @line.sub!(regex,by)
        @continue = true
      else
        STDERR.puts "S05: Step #{step} in fragment '#{@line.chomp}' failed"
        @continue = false
      end
    end
  end

  def puts
    @continue && STDOUT.puts(@line)
  end
end

while( line = gets ) do
  l = Line.new( line )
  # => Processing FrontendController#index (for 174.129.174.183 at 2010-08-11 02:37:47) [GET],Completed in 21ms (View: 18, DB: 3) | 302 Found [http://leihs.zhdk.ch/]

  l.replace(/^Processing .* \(for .* at /, '"', 0)
  # => "2010-08-11 02:37:47) [GET],Completed in 21ms (View: 18, DB: 3) | 302 Found [http://leihs.zhdk.ch/]

  l.replace(/\) \[/, '",', 1)
  # => "2010-08-11 02:37:47",GET],Completed in 21ms (View: 18, DB: 3) | 302 Found [http://leihs.zhdk.ch/]

  l.replace(/\],Completed in /, ',', 2)
  # => "2010-08-11 02:37:47",GET,21ms (View: 18, DB: 3) | 302 Found [http://leihs.zhdk.ch/]

  l.replace(/ms \(/, ',', 3)
  # => "2010-08-11 02:37:47",GET,21,View: 18, DB: 3) | 302 Found [http://leihs.zhdk.ch/]

  l.replace(/, DB: /, ',DB: ', 4)
  # => "2010-08-11 02:37:47",GET,21,View: 18,DB: 3) | 302 Found [http://leihs.zhdk.ch/]

  l.replace(/\) \| /, ',', 5)
  # => "2010-08-11 02:37:47",GET,21,View: 18,DB: 3,302 Found [http://leihs.zhdk.ch/]

  l.replace(/ \w+ \[/, ',', 6)
  # => "2010-08-11 02:37:47",GET,21,View: 18,DB: 3,302,http://leihs.zhdk.ch/]

  l.replace(/\]$/, '', 7)
  # => "2010-08-11 02:37:47",GET,21,View: 18,DB: 3,302,http://leihs.zhdk.ch/

  l.puts
end

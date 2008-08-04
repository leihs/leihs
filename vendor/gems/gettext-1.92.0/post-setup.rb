=begin
  post-setup.rb

  Copyright (C) 2001-2006 Masao Mutoh
  This program is licenced under the same licence as Ruby. 
=end

$:.unshift "lib"
$:.unshift "ext/gettext"

require 'gettext/utils'

begin
  GetText.create_mofiles
rescue
  puts "GetText.create_mofiles failed."
end

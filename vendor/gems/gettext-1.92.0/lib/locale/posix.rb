=begin
  locale/posix.rb 

  Copyright (C) 2002-2007  Masao Mutoh

  You may redistribute it and/or modify it under the same
  license terms as Ruby.

  $Id: posix.rb,v 1.2 2007/11/08 16:44:22 mutoh Exp $
=end

require 'locale/base'

module Locale 
  # Locale::SystemPosix module for Posix OS (Unix)
  # This is a low-level class. Application shouldn't use this directly.
  module SystemPosix
    extend SystemBase
  end
  @@locale_system_module = SystemPosix
end


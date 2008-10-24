=begin
  gettext/erb.rb - Class-based container module for GetText 

  Copyright (C) 2005,2006  Masao Mutoh

  You may redistribute it and/or modify it under the same
  license terms as Ruby.

  $Id: container.rb,v 1.6 2006/06/11 15:36:20 mutoh Exp $
=end

require 'gettext'

module GetText 
  # Deprecated. You don't need this. Use GetText instead.
  module Container
    include GetText
  end
end

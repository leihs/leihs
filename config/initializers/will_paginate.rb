# https://github.com/mislav/will_paginate/wiki/Troubleshooting

require 'will_paginate/array'

class Array
  include DefaultPagination::Collection
end

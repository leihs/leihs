class RunningLine < ActiveRecord::Base
  # TODO do we really need this class ?? is actually instanciated as ItemLine

  # NOTE prevent to instantiate ItemLine
  #self.inheritance_column = nil

  #belongs_to :model
  #belongs_to :inventory_pool

end

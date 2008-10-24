class Wizard < ActiveRecord::Base
  self.abstract_class = true

  validates_uniqueness_of :name
end

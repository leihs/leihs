class Property < ActiveRecord::Base

  belongs_to :model
  # TODO belongs_to :key

  validates_presence_of :key, :value

end


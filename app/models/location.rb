class Location < ActiveRecord::Base

  belongs_to :inventory_pool
  has_many :items

end

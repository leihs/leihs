class Location < ActiveRecord::Base

  belongs_to :inventory_pool
  has_many :items

  acts_as_ferret :fields => [ :building, :room, :shelf ]

  def to_s
    "#{building} #{room} #{shelf}" #TODO: Removed inventory_pool.name because it throws an error on Location.new
  end

end

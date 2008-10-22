class Location < ActiveRecord::Base

  belongs_to :inventory_pool
  has_many :items

  acts_as_ferret :fields => [ :building, :room, :shelf ]

  def to_s
    "#{inventory_pool.name} - #{building} #{room} #{shelf}"
  end

end

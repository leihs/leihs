class Location < ActiveRecord::Base

  belongs_to :inventory_pool
  has_many :items

  def to_s
    "#{building} #{room} #{shelf}"
  end

end

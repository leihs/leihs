class Location < ActiveRecord::Base

  belongs_to :inventory_pool
  has_many :items
#  has_many :models, :through => :items, :uniq => true

  define_index do
    indexes :building, :sortable => true
    indexes :room, :sortable => true
    indexes :shelf, :sortable => true
    has :id
    set_property :order => :room
    set_property :delta => true
  end

  def to_s
    "#{building} #{room} #{shelf}" #TODO: Removed inventory_pool.name because it throws an error on Location.new
  end

end

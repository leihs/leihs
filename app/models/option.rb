class Option < ActiveRecord::Base
  belongs_to :inventory_pool

  validates_presence_of :inventory_pool

  acts_as_ferret :fields => [ :inventory_code, :name ], :store_class_name => true, :remote => true

  def to_s
    name
  end
 
end
 
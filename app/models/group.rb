class Group < ActiveRecord::Base
  belongs_to :inventory_pool
  has_and_belongs_to_many :users

  validates_presence_of :inventory_pool_id
  validates_presence_of :name

  define_index do
    indexes :name, :sortable => true

    has :inventory_pool_id
  end
end

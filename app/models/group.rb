class Group < ActiveRecord::Base
  belongs_to :inventory_pool
  has_and_belongs_to_many :users

  validates_presence_of :inventory_pool_id #tmp#2
  validates_presence_of :name

#tmp#2 named_scope :general, :conditions => {:name => 'General', :inventory_pool_id => nil}

  define_index do
    indexes :name, :sortable => true

    has :inventory_pool_id

    set_property :delta => true
  end

  GENERAL_GROUP_ID = nil
  
##########################################

  def to_s
    name
  end

end

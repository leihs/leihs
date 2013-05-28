class Group < ActiveRecord::Base
  include Availability::Group

  belongs_to :inventory_pool

  has_and_belongs_to_many :users
  
  has_many :partitions, :dependent => :restrict
  accepts_nested_attributes_for :partitions, :allow_destroy => true
  has_many :models, :through => :partitions, :uniq => true, :dependent => :restrict

  validates_presence_of :inventory_pool_id #tmp#2
  validates_presence_of :name

#tmp#2 scope :general, where(:name => 'General', :inventory_pool_id => nil)

##########################################

  scope :search, lambda { |query|
    return scoped if query.blank?

    q = query.split.map{|s| "%#{s}%"}
    where(arel_table[:name].matches_all(q))
  }

##########################################

  def to_s
    name
  end
end

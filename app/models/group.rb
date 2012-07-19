class Group < ActiveRecord::Base
  include Availability::Group
  acts_as_audited :associated_with => :inventory_pool

  belongs_to :inventory_pool
  has_and_belongs_to_many :users
  has_many :partitions # FIXME cascade delete ?? 
  has_many :models, :through => :partitions, :uniq => true

  validates_presence_of :inventory_pool_id #tmp#2
  validates_presence_of :name

#tmp#2 scope :general, where(:name => 'General', :inventory_pool_id => nil)

##########################################

  def self.search2(query)
    return scoped unless query

    w = query.split.map do |x|
      "name LIKE '%#{x}%'"
    end.join(' AND ')
    where(w)
  end

##########################################

  def to_s
    name
  end

end


# == Schema Information
#
# Table name: groups
#
#  id                :integer(4)      not null, primary key
#  name              :string(255)
#  inventory_pool_id :integer(4)
#  delta             :boolean(1)      default(TRUE)
#  created_at        :datetime
#  updated_at        :datetime
#

class Group < ActiveRecord::Base
  include Availability::Group

  belongs_to :inventory_pool
  has_and_belongs_to_many :users
  has_many :partitions
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


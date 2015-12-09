class Group < ActiveRecord::Base
  include Availability::Group
  include Search::Name
  audited

  belongs_to :inventory_pool

  has_and_belongs_to_many :users

  has_many :partitions, dependent: :restrict_with_exception
  accepts_nested_attributes_for :partitions, allow_destroy: true
  has_many(:models,
           -> { uniq },
           through: :partitions,
           dependent: :restrict_with_exception)

  validates_presence_of :inventory_pool_id # tmp#2
  validates_presence_of :name

  # tmp#2 scope :general, -> {where(:name => 'General', :inventory_pool_id => nil)}

  ##########################################

  def to_s
    name
  end
end

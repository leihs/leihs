class Location < ActiveRecord::Base

  has_many :items
  belongs_to :building
  
  validates_uniqueness_of :building_id, :scope => [:room, :shelf]

#temp# 1108**
#  before_save do |record|
#    attributes[:building_id] = nil if attributes[:building_id].blank?
#    attributes[:room] = nil if attributes[:room].blank?
#    attributes[:shelf] = nil if attributes[:shelf].blank?
#  end

  def self.find_or_create(attributes = {})
    attributes.delete(:id)
    attributes.delete("id")
    attributes[:building_id] = nil if attributes[:building_id].blank?
    attributes[:room] = nil if attributes[:room].blank?
    attributes[:shelf] = nil if attributes[:shelf].blank?
    
    record = first(:conditions => attributes)
    record ||= create(attributes)
  end

  acts_as_ferret :fields => [ :building_name, :room, :shelf ], :store_class_name => true, :remote => true

  def to_s
    "#{building} #{room} #{shelf}"
  end

  private
  
  def building_name
    building.name
  end

end

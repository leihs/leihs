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

  def to_s
    "#{building} #{room} #{shelf}"
  end

#################################################################

  default_scope :include => :building

#################################################################

  define_index do
    indexes :room, :sortable => true
    indexes :shelf, :sortable => true
    indexes building(:name), :as => :building_name, :sortable => true 

    indexes :id # 0501 forcing indexer even if blank attributes, validates_presence_of :room ???

    has :building_id
    has items(:inventory_pool_id), :as => :inventory_pool_id

    # set_property :order => :room
    set_property :delta => true
  end

  # TODO 0501
  default_sphinx_scope :default_search
  sphinx_scope(:default_search) { {:order => :room, :sort_mode => :asc} }

  def touch_for_sphinx
    @block_delta_indexing = true
    touch
  end

#################################################################

end
